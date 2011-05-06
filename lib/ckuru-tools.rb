# $Id$

# Equivalent to a header guard in C/C++
# Used to prevent the class/module from being loaded more than once
unless defined? CkuruTools

  class Module
    def instance_of_class_accessor( klass, *symbols )

      symbols.each do |symbol|
        module_eval( "def #{symbol}() @#{symbol}; end" )
        module_eval( "def #{symbol}=(val) raise ArgumentError.new('#{symbol} must be a #{klass}') unless val.class.inherits_from? #{klass} ; @#{symbol} = val; end" )
      end
    end
    def class_accessor( klass, *symbols )
      symbols.each do |symbol|
        module_eval( "def #{symbol}() @#{symbol}; end" )
        module_eval( "
def #{symbol}=(val) 
  raise ArgumentError.new('argument to #{symbol} must be a class') unless val.is_a? Class
  raise ArgumentError.new('#{symbol} must be a #{klass}') unless val.inherits_from? #{klass} 
  @#{symbol} = val
end" )
      end
    end

      # raise ArgumentError.new("assignment must be of class CkuruTools::TypedArray, not \#{arr.class}") unless arr.instance_inherits_from? CkuruTools::TypedArray 
      # raise ArgumentError.new("TypedArray must require #{klass}") unless arr.required_type == #{klass}
    def typed_array_accessor(klass,*symbols)
      symbols.each do |symbol|
        module_eval( "def #{symbol}() @#{symbol}; end" )
        module_eval <<"EOF"
    def #{symbol}=(arr)
      @#{symbol} = CkuruTools::TypedArray.new(#{klass})
      arr.each do |elem|
        @#{symbol}.push elem
      end
      @#{symbol}
    end
EOF
      end
    end
  end

  module CkuruTools

    def self.parameters(h,*args)
      raise ArgumentError.new("argument to #{self.class}##{current_method} must be of class Hash; you may get this error if you don't call a function with a hash; check the initial call") unless h.is_a? Hash
      ret = []
      args.each do |a|
        name,options = a
        options = options || {}
        unless h[:no_recurse]
          vals = only_these_parameters(
                                       options.merge!(:no_recurse => true),
                                       [:instance_that_inherits_from, {:instance_of => Class}],
                                       [:instance_of, {:instance_of => Class}],
                                       [:klass_that_inherits_from, {:instance_of => Class}],
                                       [:klass_of, {:instance_of => Class}],
                                       [:no_recurse, {:instance_of => TrueClass}],
                                       [:required, {:instance_of => TrueClass}],
                                       [:default, {:instance_of => TrueClass}]
                                       )
          instance_that_inherits_from, instance_of, klass_that_inherits_from, klass_of, no_recurse, required, default = vals
        end

        if val = h[name]
          if instance_that_inherits_from 
            unless val.class.inherits_from? instance_that_inherits_from
              raise ArgumentError.new(
                                      "argument :#{name} to #{self.class}##{calling_method} must be an instance that inherits from #{instance_that_inherits_from}, #{val.class} does not") 
            end
          elsif instance_of
            unless val.class == instance_of
              raise ArgumentError.new(
                                      "argument :#{name} to #{self.class}##{calling_method} must be an instance of class #{instance_of}, not #{val.class}")
            end
          elsif klass_that_inherits_from
            unless val.inherits_from? klass_that_inherits_from
              raise ArgumentError.new("argument :#{name} to #{self.class}##{calling_method} must inherits from class #{klass_that_inherits_from}, #{val} does not") 
            end
          elsif klass_of
            unless val == klass_to
              raise ArgumentError.new("argument :#{name} to #{self.class}##{calling_method} must be of class #{klass_of}, not #{val}") 
            end
          end
        else
          if options[:default]
            val = options[:default]
          elsif options[:required]
            raise ArgumentError.new("argument :#{name} to #{self.class}##{calling_method} is required")
          end
        end
        ret.push val
      end
      ret
    end


    def self.only_these_parameters(h,*args)
      ret = parameters(h,*args)
      keys = h.keys
      args.each do |a|
        name,options = a
        keys.delete name
      end
      if keys.length > 0
        raise ArgumentError.new("unknown parameters #{keys.inspect} passed to #{self.class}##{calling_method}")
      end
      ret
    end

    def self.validate_hash_arguments(h,*args)
      raise ArgumentError.new("argument to #{current_method} must be of class Hash") unless h.is_a? Hash
      ret = []
      _calling_method = calling_method
      args.each do |a|
        name,options = a
        options = options || {}
        unless h[:no_recurse]
          vals = only_these_parameters(
            options.merge!(:no_recurse => true),
            [:instance_that_inherits_from, {:instance_of => Class}],
            [:instance_of, {:instance_of => Class}],
            [:klass_that_inherits_from, {:instance_of => Class}],
            [:klass_of, {:instance_of => Class}],
            [:no_recurse, {:instance_of => TrueClass}],
            [:required, {:instance_of => TrueClass}],
            [:default, {:instance_of => TrueClass}]
            )
          instance_that_inherits_from, instance_of, klass_that_inherits_from, klass_of, no_recurse, required, default = vals
        end

        if val = h[name]
          if instance_that_inherits_from 
            unless val.class.inherits_from? instance_that_inherits_from
              raise ArgumentError.new(
                "argument :#{name} to #{_calling_method} must be an instance that inherits from #{instance_that_inherits_from}, #{val.class} does not") 
            end
          elsif instance_of
            if instance_of.is_a? Array
              good = false
              instance_of.each do |_instance_of|
                if val.class == _instance_of
                  good = true
                  break
                end
              end
              unless good
                raise ArgumentError.new(
                  "argument :#{name} to #{_calling_method} must be an instance of class #{instance_of.join(',')}, not #{val.class}")
              end
            else
              unless val.class == instance_of
                raise ArgumentError.new(
                  "argument :#{name} to #{_calling_method} must be an instance of class #{instance_of}, not #{val.class}")
              end
            end
          elsif klass_that_inherits_from
            unless val.inherits_from? klass
              raise ArgumentError.new("argument :#{name} to #{_calling_method} must inherits from class #{klass_that_inherits_from}, #{val} does not") 
            end
          elsif klass_of
            unless val == klass_of
              raise ArgumentError.new("argument :#{name} to #{_calling_method} must be of class #{klass_of}, not #{val}") 
            end
          end
        else
          if options[:default]
            val = options[:default]
          elsif options[:required]
            raise ArgumentError.new("argument :#{name} to #{_calling_method} is required")
          end
        end
        ret.push val
      end
      ret
    end


    def self.class_space
      ret = TypedArray.new(Class)
      ObjectSpace.each_object {|x| ret.push(x) if x.is_a? Class}
      ret.uniq
    end

    # :stopdoc:
    LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
    PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
    # :startdoc:

    # Returns the version string for the library.
    #
    def self.version
      VERSION
    end

    # Returns the library path for the module. If any arguments are given,
    # they will be joined to the end of the libray path using
    # <tt>File.join</tt>.
    #
    def self.libpath( *args )
      args.empty? ? LIBPATH : ::File.join(LIBPATH, *args)
    end

    # Returns the lpath for the module. If any arguments are given,
    # they will be joined to the end of the path using
    # <tt>File.join</tt>.
    #
    def self.path( *args )
      args.empty? ? PATH : ::File.join(PATH, *args)
    end

    # Utility method used to rquire all files ending in .rb that lie in the
    # directory below this file that has the same name as the filename passed
    # in. Optionally, a specific _directory_ name can be passed in such that
    # the _filename_ does not have to be equivalent to the directory.
    #
    def self.require_all_libs_relative_to( fname, dir = nil )
      dir ||= ::File.basename(fname, '.*')
      search_me = ::File.expand_path(
                                     ::File.join(::File.dirname(fname), dir, '**', '*.rb'))

      Dir.glob(search_me).sort.each {|rb| require rb}
    end

    #
    # extending HashInitalizerClass enables you to get Object.new(hash) functionality
    # where each key will dispatch to an object setter method.
    #
    # Usage:
    #
    # class MyClass < HashInitalizerClass
    # ..attr_accessor :foo
    # end
    #
    # m = MyClass(:foo => "bar")
    # m.foo
    # => "bar"
    #
    #
    
    class HashInitializerClass
      # check for required attributes
      def required_attributes(*symbols)
        symbols.each do |symbol|
          raise ArgumentError.new("attribute :#{symbol} must be set in #{self.class}.initialize") if self.send(symbol).nil?
        end
      end
      
      # parse and return parameters from a hash
      #
      #       view = only_these_parameters(h,[:view,{:klass => View,:required => true}])
      # or
      #
      #       view = parameters(h,[:view,{:klass => View,:required => true}])

      def parameters(h,*args)
        CkuruTools.parameters(h,args)
      end

      # insure that only the defined parameters have been passed to a function
      def only_these_parameters(h,*args)
        CkuruTools.only_these_parameters(h,args)
      end


      def initialize(h={})
        raise ArgumentError.new("argument to #{self.class}##{current_method} must be of class Hash") unless h.is_a? Hash
        h.keys.each do |k|
          self.send("#{k}=",h[k])
        end

        yield self if block_given?
      end
    end

  end  # module CkuruTools

  CkuruTools.require_all_libs_relative_to __FILE__
  CkuruTools.require_all_libs_relative_to CkuruTools.libpath

  #
  # class Foo < ActiveRecord::Base
  # end
  # 
  # Foo.inherits_from? ActiveRecord::Base      
  # => true
  # 
  class Class

    # show's live decendants of this class
    def decendants
      CkuruTools.class_space.select {|x| x.inherits_from? self and x != self}
    end
      
    def inherits_from?(klass)
      raise ArgumentError.new("argument must be of type Class") unless klass.is_a? Class
      if klass == self
        true
      elsif self.superclass.is_a? Class
        self.superclass.inherits_from? klass
      else
        false
      end
    end
  end

  class Array
    def to_comma_separated_string
      ret = ''
      self.each do |elem|
        ret += ',' if ret.length > 0
        ret += elem.to_s
      end
      ret
    end
  end

  class Object
    # this method allows a an 'initialize' method to define itself as a abstract class; yet still run some code. 
    #
    # To use effectively place at the last line of an initialize method like so:
    #
    #  class DataSource < ::CkuruTools::HashInitializerClass
    #    def initialize(h={})
    #      super h
    #      this_is_an_abstract_constructor_for AuraVisualize::DataSource
    #    end
    #  end

    def this_is_an_abstract_constructor_for(klass)
      unless self.class.superclass.inherits_from? klass # abstract constructor
        str = ''
        self.class.decendants.each do |d|
          str += "#{d}\n"
        end
        raise <<"EOF" 
Do not call method of #{self.class}.#{calling_method} directly, you must instantiate a base class.

Maybe you want one of these?:

#{str}
EOF
      end
    end
      
    # see if this object's class inherits from another class
    def instance_inherits_from?(klass)
      self.class.inherits_from?(klass)
    end

    def _require ; each {|r| require r } ; end

    def docmd(cmd,dir=nil)
      ret = docmdi(cmd,dir)
      if ret.exitstatus != 0
        raise "cmd #{cmd} exitstatus #{ret.exitstatus} : #{ret}"
      end
      ret
    end

    def docmdi(cmd,dir=nil)
      if dir
        unless Dir.chdir(dir) 
          ckebug 0, "failed to cd to #{dir}"
          return nil
        end
      end
      ret = msg_exec "running #{cmd}" do
        cmd.gsub!(/\\/,"\\\\\\\\\\\\\\\\")
        cmd.gsub!(/\'/,"\\\\'")
        cmd.gsub!(/\"/,"\\\\\\\\\\\"")
        system("bash -c \"#{cmd}\"")
        if $?.exitstatus != 0 
          print " failed exit code #{$?.exitstatus} "
        end
      end
      $?
    end
        
    ################################################################################

    def docmd_dir(h={})
      ret = nil
      if h[:dir]
        unless Dir.chdir(h[:dir]) 
          ckebug 0, "failed to cd to #{h[:dir]}"
          return nil
        end
      end
      if h[:commands]
        h[:commands].each do |cmd|
          ret = docmd(cmd)
          if ret.exitstatus != 0
            ckebug 0, "giving up"
            return ret
          end
        end
      end
      ret
    end

    def emacs_trace
      begin
        yield
      rescue Exception => e
        puts e
        puts "... exception thrown from ..."
        e.backtrace.each do |trace|
          a = trace.split(/:/)
          if a[0].match(/^\//)
            puts "#{a[0]}:#{a[1]}: #{a[2..a.length].join(':')}"
          else
            d = File.dirname(a[0])
            f = File.basename(a[0])
            dir = `cd #{d}; pwd`.chomp
            goodpath = File.join(dir,f)

            puts "#{goodpath}:#{a[1]}: #{a[2..a.length].join(':')}"              
          end
          if $emacs_trace_debugger
            require 'ruby-debug'
          end
        end
        raise "sorry ...exiting"
      end
    end

    def ckebug(level,msg)      
      CkuruTools::Debug.instance.debug(level,msg)
    end

    def current_method
      caller[0].match(/`(.*?)'/)[1]
    end

    def calling_method
      caller[1] ? caller[1].match(/`(.*?)'/)[1] : ""
    end

    def calling_method2
      if caller[2]
        if matchdata = caller[2].match(/`(.*?)'/)
          matchdata[1]
        else
          ""
        end
      else
        ""
      end
    end

    def calling_method3
      if caller[3]
        if matchdata = caller[3].match(/`(.*?)'/)
          matchdata[2]
        else
          ""
        end
      else
        ""
      end
    end



    def calling_method_sig
      caller[1] ? caller[1] : ""
    end

      

#     def calling_method
#       if caller[2]
#         caller[2].match(/`(.*?)'/)[1]
#       else
#         ""
#       end
      
#     end

  end
end

class Time
  def ckuru_time_string
    strftime("%m/%d/%Y %H:%M:%S")
  end
end

def printmsg(msg,newline=true)
  print "#{Time.new.ckuru_time_string}: #{msg}"
  puts if newline
end


#module MlImportUtils
def msg_exec(msg)
  printmsg("#{msg} ... ",false)
  t1 = Time.new
  ret = yield
  puts "done (#{Time.new - t1})"
  ret
end

def chatty_exec(level,name)
  ret = yield
  ckebug level, "#{name} is #{ret}"
  ret
end


# EOF
