How to copy texts from one project to another

First of all, gather than all in a view - in this case I call the view "MOVED"
then you can use the following

sample ruby (requires class to be copied and pasted into console at present)

```ruby
messaging = Project.find(5)
moved_view = View.find(30)
CopyTextsCommand.new(moved_view, messaging).copy_all
```

class: need to extract and make tests etc.
```ruby
class CopyTextsCommand
  # @return [View]
  attr_reader :from_view
  # @return [Project]
  attr_reader :from_project
  # @return [Project]
  attr_reader :to_project
  # @return [Hash{Integer => Integer}]
  attr_reader :project_language_id_lookup
  # @return [Array<ProjectLanguage>]
  attr_reader :untranslated_project_languages

  def initialize(from_view, to_project)
    raise "from_view must be a View not a #{from_view.class.name}" unless to_project.is_a?(Project)
    raise "to_project must be a Project not a #{to_project.class.name}" unless from_view.is_a?(View)
    raise "Can't copy to same project" if from_view.project == to_project

    @from_view = from_view
    @from_project = from_view.project
    @to_project = to_project
    @project_language_id_lookup = from_project.project_languages.to_h do |project_language|
      [project_language.id, to_project.project_languages.detect{|pl2| pl2.language_id == project_language.language_id}.id]
    end
    @untranslated_project_languages = to_project.project_languages.reject{|pl| to_project.project_languages.map(&:language_id).include?(pl.language_id)}
  end

  def copy_all
    to_copy = from_view.master_texts.reject{|mt| to_project.master_texts.pluck(:key).include?(mt.key)}
    copied = []
    to_copy.each { |mt| copied << copy_one(mt) }
    to_project.recalculate_counts!
    to_project.views.create!(name: "Copied from #{from_project.name} @#{Time.zone.now.strftime('%Y-%m-%d-%H%M')}")
  end

  def copy_one(mt)
    new_mt = to_project.master_texts.create!(mt.attributes.except(*%w[id created_at project_id updated_at]))
    mt.localized_texts.each do |lt|
      new_lt = new_mt.localized_texts.new(lt.attributes.except(*%w[id master_text_id needs_review created_at updated_at needs_entry project_language_id translated_from translated_at]))
      new_lt.assign_attributes(project_language_id: project_language_id_lookup[lt.project_language_id])
      new_lt.save!
    end
    untranslated_project_languages.each { |project_language| new_mt.localized_texts.create!(project_language: project_language) }
    new_mt
  end
end
```
