require './model'

use Rack::Session::Pool, expire_after: 2592000

get '/' do
  @user = session[:user]
  if @user
    erb :home
  else
    redirect '/login'
  end
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
    redirect session.delete(:return_to)
  else
    redirect '/login'
  end
end

get '/sign_up' do
  @title = 'sign_up'
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

#############################
# Questions

get '/ask' do
  check_login
  erb :ask
end

post '/question' do
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

delete '/question/:id' do
  q = Question.find(paramas[:id]).destroy
  redirect request.referer
end
#############################
# Answers

post '/question/:id/answer' do
  check_login
  answer = Answer.new(content: params[:content],
                       question_id: params[:id],
                       user_id: session[:user].id)
  answer.save
  redirect "/question/#{params[:id]}"
end

put '/answer/:id' do
  answer = Answer.find(params[:id])
  answer.content = params[:content]
  answer.save
  redirect "/question/#{answer.question.id}"
end

delete '/answer/:id' do
  Answer.find(params[:id]).destroy
  redirect request.referer
end
  
post '/answer/:id/comment' do
  check_login
  comment = Comment.new(content: params[:content],
                        answer_id: params[:id],
                        user_id: session[:user].id)
  comment.save
  redirect ''
end

delete '/comment/:id' do
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

get '/question/:id/addtopic' do
  #check_login

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
  check_login

  topic_id = Topic.find_by(name: params[:topic])
  halt 404 unless topic_id

  qt = QuestionsTopic.where("topic_id = ? AND question_id = ?",
                            topic_id,
                            params[:id]).first
  qt.destroy if qt

  redirect request.referer
end


get '/search_topic' do
  @results = Topic.where("name like ?", "%#{params[:q]}%")
  erb :search_topic, layout: false
end

############################################
# Followings
get '/user/:id' do
  @user = User.find(params[:id])
  erb :user_page
end

get '/followuser/:id' do
  check_login

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


helpers do
  def title
    @title ? @title : 'しるか'
  end

  def check_login
    if session[:user]
      return
    else
      session[:return_to] ||= request.referer
      #redirect '/login'
      halt 401 
    end
  end

  def check_vote(answer_id)
    check_login

    answer = Answer.find(answer_id)
    halt 404 unless answer

    # One could not vote for his own answer
    if answer.user_id == session[:user].id
      redirect request.referer
    end

    vote = Vote.find_by(user_id: session[:user].id,
                        answer_id: answer.id)
  end

  def user_in_ids?(*ids)
    session[:user] && ids.include?(session[:user].id)
  end
end   

