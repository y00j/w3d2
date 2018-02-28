require 'sqlite3'
require 'singleton'


class PlayDBConnection < SQLite3::Database

  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end

end


class User
  attr_accessor :fname, :lname

  def self.find_by_name(fname, lname)
    data = PlayDBConnection.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil unless data.length > 0

    User.new(data.first)
  end

  def self.find_by_id(author_id)
    data = PlayDBConnection.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil unless data.length > 0

    User.new(data.first)
  end



  def self.all
    data = PlayDBConnection.instance.execute("SELECT * FROM users")
    data.map {|datum| User.new(datum)}
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




end



class Question

  attr_accessor :title, :body, :author_id

  def self.find_by_author_id(author_id)
    data = PlayDBConnection.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    return nil unless data.length > 0

    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_id(question_id)
    data = PlayDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL

    Question.new(data.first)
  end

  def self.all
    data = PlayDBConnection.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def author
    User.find_by_id(@author_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollower.followers_for_question_id(@id)
  end

end

class QuestionFollow

  def self.most_followed_questions(n)
    data = PlayDBConnection.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions
      JOIN question_follows
        ON question_follows.question_id = questions.id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(question_id)
      LIMIT
        ?
    SQL

  end

  def self.followers_for_question_id(question_id)
    data = PlayDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        question_follows.user_id AS id, fname, lname
      FROM
        question_follows
      JOIN users
        ON question_follows.user_id = users.id
      WHERE
        question_id = ?
    SQL
    return nil unless data.length > 0

    data.map { |datum| User.new(datum) }
  end

  def self.followed_questions_for_user(user_id)
    data = PlayDBConnection.instance.execute(<<-SQL, user_id)
    SELECT
      questions.id AS id, title, body, author_id
    FROM
      question_follows
    JOIN questions
      ON question_follows.question_id = questions.id
    WHERE
      questions.id = ?
    SQL

    data.map {|datum| Question.new(datum)}
  end



  def self.all
    data = PlayDBConnection.instance.execute("SELECT * FROM question_follows")
    data.map {|datum| QuestionsFollow.new(datum)}
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

end

class Reply

  def self.find_by_user_id(user_id)
    data = PlayDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil unless data.length > 0

    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_question_id(question_id)
    data = PlayDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    return nil unless data.length > 0

    data.map { |datum| Reply.new(datum) }
  end

  def self.all
    data = PlayDBConnection.instance.execute("SELECT * FROM replies")
    data.map {|datum| Reply.new(datum)}
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
    @body = options['body']
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    raise " You are the parent reply" if @parent_id == nil
    data = PlayDBConnection.instance.execute(<<-SQL,@parent_id )
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL

    Reply.new(data.first)
  end

  def child_replies
    data = PlayDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL

    return nil unless data.length > 0

    data.map {|datum| Reply.new(datum)}
  end

end

class QuestionLike

  def self.all
    data = PlayDBConnection.instance.execute("SELECT * FROM question_likes")
    data.map {|datum| QuestionLike.new(datum)}
  end

  def initialize(options)
    @id = options['id']
    @like_status = options['like_status']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

end
