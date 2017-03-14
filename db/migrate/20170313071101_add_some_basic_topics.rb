class AddSomeBasicTopics < ActiveRecord::Migration[5.0]
  def change
    basic_topics = ['Ruby', '数学', 'ACG', '社会科学', '宗教', '文学',
                    '旅行', '经济', '运动', '科技', '计算机科学',
                    '电影', '艺术', '音乐', '设计', '政治', '日语',
                    '德语', '哲学',]
    basic_topics.each do |topic|
      Topic.create(name: topic)
    end
  end
end
