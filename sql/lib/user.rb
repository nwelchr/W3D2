require_relative 'model_base'

class User < ModelBase

  attr_accessor :fname, :lname

  def self.find_by_name(fname, lname)
    users = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL

    User.new(users.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    like_sum = 0
    questions = QuestionLike.liked_questions_for_user_id(@id)
    questions.each do |question|
      like_sum += QuestionLike.num_likes_for_question_id(question.id)
    end
    p like_sum
    p questions.count
    like_sum.fdiv(questions.count)
  end

end
