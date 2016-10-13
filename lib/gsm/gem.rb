module Gsm
  class Gem

    attr_reader :conf_path, :name_pivot
    attr_reader :sources
    attr_reader :use_name

    MAX_GENERATED_NAMES = 11
    GEMSTONE_NAMES = [
      "Amethyst",
      "Emerald",
      "Chrysocolla",
      "Hematite",
      "Jasper",
      "Malachite",
      "Quartz",
      "Ruby",
      "Sapphire",
      "Sugilite",
      "Turquoise"
    ].freeze

    def initialize(conf_path)
      @sources = Hash.new
      @name_pivot = 0
      @conf_path = conf_path

      if !load_from_yaml?
        # load from `gem sources`
        load

        @use_name = ""
      end
    end

    def load
      outputs = `gem source -l`
      outputs.split("\n").each do |line|
        line.strip!
        if validate_url?(line)
          name = generate_name
          @sources[name] = line
        end
      end
    end

    def add(name, url)
      if @sources.has_key?(name)
        return false
      end

      # validate url
      if !validate_url?(url)
        return false
      end

      @sources[name] = url
    end

    def del(name)
      # TODO
    end

    def get
      @use_name
    end

    def use(name)
      if sources.has_key?(name)
        return false
      end

      @use_name = name
    end

    def to_s
      return if @sources[@use_name]
    end

    private
    def validate_url?(url)
      url.start_with?("http://") || url.start_with?("https://") ? true : false
    end

    private
    def load_from_yaml?
      # read yaml
      if File.exist? @conf_path
        data = YAML.load_file @conf_path
        @use_name = data["use"]
        true
      else
        f = File.new(@conf_path, "w")
        f.close
        false
      end
    end

    private
    def generate_name
      if @name_pivot >= MAX_GENERATED_NAMES - 1
        return GEMSTONE_NAMES[(++@name_pivot)-MAX_GENERATED_NAMES] << 
          "-" << 
          (@name_pivot/MAX_GENERATED_NAMES).to_s
      end

      GEMSTONE_NAMES[++@name_pivot]
    end
  end
end