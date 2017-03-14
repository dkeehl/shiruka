require 'sinatra/base'
require 'sinatra/activerecord'
require_relative 'model'

class Shiruka < Sinatra::Base

  register Sinatra::ActiveRecordExtension

  set :database, {adapter: 'sqlite3', database: 'shiruka.sqlite3'}

  use Rack::Session::Pool, expire_after: 2592000

  enable :logging
  enable :method_override

  get '/' do
    redirect '/explore'
  end

  #########################
  # Sign up and Login

  get '/login' do
    @title = 'Shiruka Login'
    erb :login
  end

  post '/login' do
    user = User.auth(params[:email], params[:password])
    if user
      session[:user] = user
      redirect session[:referer] || '/'
    else
      halt 401
    end
  end

  get '/sign_up' do
    @title = 'Sign up'
    erb :sign_up
  end

  post '/sign_up' do
    user = User.new(name: params[:name], email: params[:email])
    user.password = params[:password]
    if user.save
      session[:user] = user
      redirect '/'
    else
      redirect '/sign_up'
    end
  end

  get '/logout' do
    session[:user] = nil
    redirect '/login'
  end

  protected_src = [
    '/question/create',
    '/question/delete',
    '/question/:id/answer/create',
    '/answer/:id/update',
    '/answer/:id/delete',
    '/answer/:id/comment/create',
    '/question/:id/addtopic',
    '/question/:id/deltopic',
    '/followuser/:id',
    '/upload',
  ]

  protected_src.each do |path|
    before path do
      check_login do
        session[:referer] = request.referer
        redirect '/login'
      end
    end
  end
  #############################
  # Questions

  get '/ask' do
    erb :ask
  end

  post '/question/create' do
    user_id = session[:user].id
    q = Question.new(name: params[:name],
                     description: params[:description],
                     user_id: user_id)
    if q.save
      redirect "/question/#{q.id}"
    else
      redirect '/ask'
    end
  end

  get /\A\/question\/(?<id>\d+)\/?\Z/ do
    @question = Question.find(params[:id])
    if @question
      @title = @question.name
      erb :question
    else
      halt 404
    end
  end

  delete '/question/delete' do
    q = Question.find(paramas[:id]).destroy
    redirect request.referer
  end
  #############################
  # Answers

  post '/question/:id/answer/create' do
    answer = Answer.new(content: params[:content],
                         question_id: params[:id],
                         user_id: session[:user].id)
    answer.save
    redirect "/question/#{params[:id]}"
  end

  put '/answer/:id/update' do
    answer = Answer.find(params[:id])
    answer.content = params[:content]
    answer.save
    redirect "/question/#{answer.question.id}"
  end

  delete '/answer/:id/delete' do
    Answer.find(params[:id]).destroy
    redirect request.referer
  end
    
  post '/answer/:id/comment/create' do
    comment = Comment.new(content: params[:content],
                          answer_id: params[:id],
                          user_id: session[:user].id)
    comment.save
    redirect request.referer || '/'
  end

  delete '/comment/:id/delete' do
    Comment.find(params[:id]).destroy
    redirect request.referer
  end
  ##########################
  # Display Answers

  get '/explore' do
    answers = Answer.order(created_at: :desc)
    erb :titled_answer, locals: { answers: answers }
  end

  get '/topic/:id' do
    if @topic = Topic.find(params[:id])
      @questions = @topic.questions
      erb :topic_page
    else
      not_found
    end
  end
  #########################
  # Votes

  get '/answer/:id/upvote' do
    vote = check_vote(params[:id])

    if vote == nil
      Vote.create(user_id: session[:user].id,
                  answer_id: params[:id],
                  agree: true)
    elsif vote.agree != true 
      vote.update(agree: true)
    end

    Vote.where(answer: params[:id], agree: true).length.to_s
  end

  get '/answer/:id/downvote' do
    vote = check_vote(params[:id])

    if vote == nil
      Vote.create(user_id: session[:user].id,
                  answer_id: params[:id],
                  agree: false)
    elsif vote.agree != false
      vote.update(agree: false)
    end

    Vote.where(answer: params[:id], agree: true).length.to_s
  end

  get '/answer/:id/unvote' do
    vote = check_vote(params[:id])

    vote.update(agree: nil) if vote

    Vote.where(answer: params[:id], agree: true).length.to_s
  end

  #topics

  get '/question/:id/addtopic' do

    topic = Topic.find_by(name: params[:topic])
    halt 404 unless topic

    if QuestionsTopic.where("topic_id = ? AND question_id = ?",
                            topic.id,
                            params[:id]).length == 0
      QuestionsTopic.create(topic_id: topic.id,
                            question_id: params[:id])
    end

    redirect request.referer
  end

  get '/question/:id/deltopic' do

    topic_id = Topic.find_by(name: params[:topic])
    halt 404 unless topic_id

    qt = QuestionsTopic.where("topic_id = ? AND question_id = ?",
                              topic_id,
                              params[:id]).first
    qt.destroy if qt

    redirect request.referer
  end

  post '/question/:id/modify-topics' do
    halt 404 unless params[:topics]
    new_topics = params[:topics].split(',').map(&:to_i)

    QuestionsTopic.update_topics params[:id], new_topics
    
    halt 200
  end

  get '/search_topic' do
    @results = Topic.where("name like ?", "%#{params[:q]}%").limit(10)
    @results.select('id, name').to_json
  end

  get '/search' do
    if params[:q] && params[:q].length > 0
      @results = Answer.search(params[:q])
    else
      @results = nil
    end
    erb :search_result
  end

  ############################################
  # Followings
  get '/user/:id' do
    @user = User.find(params[:id])
    erb :user_page
  end

  get '/followuser/:id' do

    @user = User.find(params[:id])
    not_found unless @user
   
    if already_followed = @user.follower_users.find_by(follower_id: session[:user].id)
      already_followed.destroy
    else
      FollowingUser.create(follower_id: session[:user].id,
                          following_id: @user.id)
    end

    redirect request.referer
  end

########################
# file upload
  post '/upload' do
    return 'no file selected' unless params[:file]

    file = params[:file][:tempfile]
    file_name = params[:file][:filename]

    File.open("./public/img/#{file_name}", 'wb') do |f|
      f.write file.read
    end

    redirect request.referer
  end

  get '/modify-personal-info' do
    erb :user_home
  end

  helpers do
    def title
      @title ||=  'しるか'
    end

    def check_login
      yield unless session[:user]
    end

    def check_vote(answer_id)
      check_login { halt 401 }

      answer = Answer.find(answer_id)
      halt 404 unless answer

      # One could not vote for his own answer
      if answer.user_id == session[:user].id
        halt 404
      end

      vote = Vote.find_by(user_id: session[:user].id,
                          answer_id: answer.id)
    end

    def user_in_ids?(*ids)
      session[:user] && ids.include?(session[:user].id)
    end
  end   
end
