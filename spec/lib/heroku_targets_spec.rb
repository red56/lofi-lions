require "spec_helper"

describe HerokuTargets do

  valid_file = <<-VALID
  production:
    heroku_app : my-production-heroku_app
    git_remote : heroku_production
    deploy_ref : origin/master
  staging:
    heroku_app : my-staging-heroku_app
    git_remote : heroku_production
    deploy_ref : origin/master
    display_name : My Lovely Staging heroku_app
    staging : true
    db_color : NAVY
  VALID
  let(:valid_ht) { HerokuTargets.from_string(valid_file) }

  describe "wrapper class (HerokuTargets)" do
    it "should be able to find display_names" do
      expect(valid_ht.targets).to be_a(Hash)
      expect(valid_ht.targets.keys).to include("my-staging-heroku_app")
      expect(valid_ht.targets.keys).to include("my-production-heroku_app")
    end
    it "should parse targets as a HerokuTarget" do
      expect(valid_ht.targets.values.collect(&:class).uniq).to eq([HerokuTargets::HerokuTarget])
    end

    it "should be able to find staging targets" do
      expect(valid_ht.staging_targets).to be_a(Hash)
      expect(valid_ht.staging_targets.keys).to include("my-staging-heroku_app")
      expect(valid_ht.staging_targets.keys).not_to include("my-production-heroku_app")
    end

    it "should be able to find a target by heroku ref" do
      expect(valid_ht.targets['my-production-heroku_app']).to be_a(HerokuTargets::HerokuTarget)
      expect(valid_ht.staging_targets['my-staging-heroku_app']).to be_a(HerokuTargets::HerokuTarget)
    end
    it "should be able to find a target by name as well" do
      expect(valid_ht.targets[:production]).to be_a(HerokuTargets::HerokuTarget)
      expect(valid_ht.staging_targets[:staging]).to be_a(HerokuTargets::HerokuTarget)
    end
    it "should be able to find a target by string or symbol" do
      expect(valid_ht.targets["production"]).to be_a(HerokuTargets::HerokuTarget)
      expect(valid_ht.targets['my-production-heroku_app'.to_sym]).to be_a(HerokuTargets::HerokuTarget)
    end
    it "should be able to return nil if no such target" do
      expect(valid_ht.targets['whatevs']).to be_nil
      expect(valid_ht.staging_targets['whatevs']).to be_nil
    end
    it "should be able to return db_color " do
      expect(valid_ht.targets['staging'].db_color).to eq('NAVY')
      expect(valid_ht.targets['production'].db_color).to eq('DATABASE')
    end
  end
  it "our local heroku targets (if exists) should be ok" do
    targets_file = Rails.root.join('config/heroku_targets.yml')
    HerokuTargets.from_file(targets_file) if File.exists?(targets_file)
  end
  it "our heroku targets template should be ok" do
    HerokuTargets.from_file(Rails.root.join('config/heroku_targets.yml.template'))
  end

  describe HerokuTargets::HerokuTarget do
    let(:minimal_values) { {heroku_app: 'my-lovely-app', git_remote: 'heroku_branch', deploy_ref: 'HEAD'} }

    it "should work with minimal values" do
      expect(HerokuTargets::HerokuTarget.new(minimal_values)).to be_a(HerokuTargets::HerokuTarget)
    end
    it "should require heroku_app" do
      expect { HerokuTargets::HerokuTarget.new(minimal_values.except(:heroku_app)) }.to raise_error ArgumentError
    end
    it "should require deploy_ref" do
      expect { HerokuTargets::HerokuTarget.new(minimal_values.except(:deploy_ref)) }.to raise_error ArgumentError
    end
    it "should require git_remote" do
      expect { HerokuTargets::HerokuTarget.new(minimal_values.except(:git_remote)) }.to raise_error ArgumentError
    end

    it "should be not staging by default" do
      target = HerokuTargets::HerokuTarget.new(minimal_values.except(:staging))
      expect(target).not_to be_staging
    end
    it "should be staging when set" do
      target = HerokuTargets::HerokuTarget.new(minimal_values.merge(staging: true))
      expect(target).to be_staging
    end
    it "should give display_name as heroku_app if not specified" do
      target = HerokuTargets::HerokuTarget.new(minimal_values)
      expect(target.display_name).to eq(target.heroku_app)

    end
    it "should give display_name as heroku_app if not specified" do
      target = HerokuTargets::HerokuTarget.new(minimal_values.merge(display_name: "Flarrr"))
      expect(target.display_name).to eq("Flarrr")
    end
    it "should give heroku_app" do
      target = HerokuTargets::HerokuTarget.new(minimal_values)
      expect(target.heroku_app).to eq(minimal_values[:heroku_app])
    end
    it "should give git_remote" do
      target = HerokuTargets::HerokuTarget.new(minimal_values)
      expect(target.git_remote).to eq(minimal_values[:git_remote])
    end
    it "should give deploy_ref" do
      target = HerokuTargets::HerokuTarget.new(minimal_values)
      expect(target.deploy_ref).to eq(minimal_values[:deploy_ref])
    end
  end

end
