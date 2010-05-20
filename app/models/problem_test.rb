class ProblemTest < ActiveRecord::Base
  TESTS = 'judge/tests'
  
  belongs_to :problem, :counter_cache => 'tests_count'
  has_many :results, :dependent => :destroy, :foreign_key => 'test_id'

  named_scope :real, :conditions => { :hidden => true }

  after_update { |t| t.problem.test_touched! }
  
  after_save { |t| t.save_to_file! }

  def dir
    "#{RAILS_ROOT}/#{TESTS}/#{self.problem_id}"
  end

  def input_path
    "#{self.dir}/#{self.id}.in"
  end

  def output_path
    "#{self.dir}/#{self.id}.out"
  end

  def save_to_file!
    FileUtils.mkpath self.dir
    File.open(self.input_path,  'w'){|f| f.write(self.input.gsub(/\r/,'')) }
    File.open(self.output_path, 'w'){|f| f.write(self.output.gsub(/\r/,''))}
  end

  def matches?(file_path)
    `diff -b #{file_path} #{output_path}`.empty?
  end

end
