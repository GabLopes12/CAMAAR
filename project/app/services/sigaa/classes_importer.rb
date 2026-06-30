module Sigaa
  class ClassesImporter
    Result = Data.define(:created_count, :updated_count)

    DEFAULT_PATH = Rails.root.join("..", "classes.json")

    def initialize(path: DEFAULT_PATH, semester:, imported_by: nil)
      @path = path
      @semester = semester
      @imported_by = imported_by
    end

    def call
      counts = { created: 0, updated: 0 }

      entries_for_semester.each do |entry|
        attrs = extract_class_attrs(entry)
        course_class = find_course_class(attrs)
        sync_course_class(course_class, attrs, counts)
      end

      Result.new(created_count: counts[:created], updated_count: counts[:updated])
    end

    private

    attr_reader :path, :semester, :imported_by

    def entries_for_semester
      JSON.parse(File.read(path)).select do |entry|
        entry.dig("class", "semester") == semester
      end
    end

    def extract_class_attrs(entry)
      class_info = entry.fetch("class")
      {
        code: entry.fetch("code"),
        name: entry.fetch("name"),
        class_code: class_info.fetch("classCode"),
        semester: class_info.fetch("semester"),
        time: class_info["time"]
      }
    end

    def department_for(code)
      department_code = resolve_department_code(code)
      department = Department.find_or_create_by!(code: department_code) { |dept| dept.name = department_code }
      imported_by.update!(department:) if imported_by && imported_by.department_id.nil?
      department
    end

    def resolve_department_code(code)
      imported_by&.department&.code || code.to_s[/\A[A-Za-z]+/]&.upcase || "GERAL"
    end

    def find_course_class(attrs)
      CourseClass.find_by(code: attrs[:code], class_code: attrs[:class_code], semester: attrs[:semester])
    end

    def sync_course_class(course_class, attrs, counts)
      if course_class.nil?
        CourseClass.create!(attrs.merge(department: department_for(attrs[:code])))
        counts[:created] += 1
      elsif course_class_attributes_changed?(course_class, attrs)
        course_class.update!(attrs.slice(:name, :time))
        counts[:updated] += 1
      end
    end

    def course_class_attributes_changed?(course_class, attrs)
      course_class.name != attrs[:name] || course_class.time != attrs[:time]
    end
  end
end
