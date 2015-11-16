class NameCollisionError < StandardError
  attr_accessor :name

  def initialize(name)
    @name = name
    super(message)
  end

  def to_s
    "The name #{@name} is already taken!"
  end
end

class Robot
  attr_accessor :name

  @@registry

  def initialize(args = {})
    @@registry ||= []
    @name_generator = args[:name_generator]

    @name = generate_name(@name_generator)
    raise NameCollisionError.new(@name), 'There was a problem ' \
      'generating the robot name!' if invalid_name?(@name)

    @@registry << @name
  end

  def generate_name(name_generator)
    name = name_generator.call if name_generator

    while invalid_name?(name)
      name_generator = create_random_generator
      name = name_generator.call
    end

    name
  end

  def create_random_generator
    generate_char = -> { ('A'..'Z').to_a.sample }
    generate_num = -> { rand(10) }
    lambda do
      "#{generate_char.call}#{generate_char.call}" \
      "#{generate_num.call}#{generate_num.call}#{generate_num.call}"
    end
  end

  def invalid_name?(name)
    name.nil? ||
      @@registry.include?(name) ||
      !(name =~ /[[:alpha:]]{2}[[:digit:]]{3}/)
  end
end
