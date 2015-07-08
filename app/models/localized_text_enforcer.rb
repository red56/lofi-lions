class LocalizedTextEnforcer

  #called after a master text is created. Assume no localized texts are created.
  def master_text_created(master_text)
    master_text.project.project_languages.all.each do |project_language|
      master_text.localized_texts.create!(project_language: project_language)
    end
  end

  #used when a master text is changed. Assume localized texts are all created.
  def master_text_changed(master_text)
    master_text.localized_texts.where(needs_entry: false).update_all(needs_review: true)
  end

  def project_language_created(project_language)
    project_language.project.master_texts.each do |master_text|
      master_text.localized_texts.create!(project_language: project_language)
    end
    project_language.recalculate_counts!
  end

  def language_created(language)
    Project.all.each do |project|
      project_language = project.project_languages.create!(language: language)
      project_language_created(project_language)
    end
  end

  class MasterTextCrudder
    def self.create_or_update(key, text_or_text_hash, project_id, raise_exception = false)
      MasterText.find_or_initialize_by(key: key, project_id: project_id).tap do |master_text|
        if text_or_text_hash.is_a? Hash
          master_text.one = text_or_text_hash[:one]
          master_text.other = text_or_text_hash[:other]
          master_text.pluralizable = true
        else
          master_text.other = text_or_text_hash
          master_text.pluralizable = false
        end
        new(master_text).save_with_exception(raise_exception)
      end
    end

    def self.create_or_update!(key, text_or_text_hash, project_id)
      create_or_update(key, text_or_text_hash, project_id, true)
    end

    def initialize(master_text)
      @master_text = master_text
    end

    def save!
      save_with_exception(true)
    end

    def save
      save_with_exception(false)
    end

    def save_with_exception(raise_exception)
      was_new_record = @master_text.new_record?
      text_changed = @master_text.text_changed?
      save_method = raise_exception ? :save! : :save
      if (result = @master_text.send(save_method))
        if was_new_record
          LocalizedTextEnforcer.new.master_text_created(@master_text)
        elsif text_changed
          LocalizedTextEnforcer.new.master_text_changed(@master_text)
        end
      end
      result
    end

    def update(attrs)
      @master_text.with_transaction_returning_status do
        @master_text.assign_attributes(attrs)
        self.save
      end
    end
  end

  class ProjectLanguageCreator
    def initialize(project_language)
      @project_language = project_language
    end

    def save
      return nil unless @project_language.new_record?
      if result=@project_language.save
        LocalizedTextEnforcer.new.project_language_created(@project_language)
      end
      result
    end
  end

  class LanguageCreator
    def initialize(language)
      @language = language
    end

    def save
      return nil unless @language.new_record?
      if result=@language.save
        LocalizedTextEnforcer.new.language_created(@language)
      end
      result
    end
  end
end