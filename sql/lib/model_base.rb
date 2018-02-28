require_relative 'questions_database'
require 'byebug'
require 'active_support'

class ModelBase
  extend ActiveSupport::Inflector

  def self.find_by_id(id)
    type = tableize("#{self}")
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{type}
      WHERE
        id = ?
    SQL

    case type
    when 'users'
      User.new(results.first)
    when 'replies'
      Reply.new(results.first)
    when 'questions'
      Question.new(results.first)
    when 'question_follows'
      QuestionFollow.new(results.first)
    when 'question_likes'
      QuestionLike.new(results.first)
    end
  end

  def self.all
    type = tableize("#{self}")
    results = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{type}
    SQL

    parse_results(type, results)
  end

  def self.where(options)
    if options.is_a?(Hash)
      where_string = ''
      options.keys.each_with_index do |key, idx|
        if options[key].is_a?(String)
          where_string += "#{key.to_s} = '#{options[key]}'"
        else
          where_string += "#{key.to_s} = #{options[key]}"
        end
        where_string += ' AND ' unless idx == options.keys.count - 1
      end
    else
      where_string = options
    end

    type = tableize("#{self}")
    results = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{type}
      WHERE
        #{where_string}
    SQL

    parse_results(type, results)
  end

  def self.parse_results(type, results)
    case type
    when 'users'
      results.map { |result| User.new(result) }
    when 'replies'
      results.map { |result| Reply.new(result) }
    when 'questions'
      results.map { |result| Question.new(result) }
    when 'question_follows'
      results.map { |result| QuestionFollow.new(result) }
    when 'question_likes'
      results.map { |result| QuestionLike.new(result) }
    end
  end

  def self.method_missing(method_name, *args)
      method_name = method_name.to_s
      if method_name.start_with?("find_by_")
        # attributes_string is, e.g., "first_name_and_last_name"
        attributes_string = method_name[("find_by_".length)..-1]

        # attribute_names is, e.g., ["first_name", "last_name"]
        attribute_names = attributes_string.split("_and_")

        unless attribute_names.length == args.length
          raise "unexpected # of arguments"
        end

        search_conditions = {}
        attribute_names.length.times do |i|
          search_conditions[attribute_names[i]] = args[i]
        end

        # Imagine search takes a hash of search conditions and finds
        # objects with the given properties.
        where(search_conditions)
      else
        # complain about the missing method
        super
      end
    end

  def save
    raise "#{self} not in database" unless @id
    variables = self.instance_variables # array of symbols

    set_string = ''
    variables.each_with_index do |variable, idx|
      next if idx == 0
      if instance_variable_get(variable).is_a?(String)
        set_string += "#{variable.to_s[1..-1]} = '#{instance_variable_get(variable)}'"
      else
        set_string += "#{variable.to_s[1..-1]} = #{instance_variable_get(variable)}"
      end
      set_string += ', ' unless idx == variables.count - 1
    end

    QuestionsDatabase.instance.execute(<<-SQL, @id)
      UPDATE
        users
      SET
        #{set_string}
      WHERE
        id = ?
    SQL
  end

end
