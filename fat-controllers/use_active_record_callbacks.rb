# before

class Article < ActiveRecord::Base

  def create_version!(attributes, user)
    if self.versions.empty?
      return create_first_version!(attributes, user)
    end
    # mark old related links as not current
    if self.current_version.relateds.any?
      self.current_version.relateds.each { |rel|
        rel.update_attribute(:current, false) }
    end
    version = self.versions.build(attributes)
    version.article_id = self.id
    version.written_at = Time.now
    version.writer_id = user.id
    version.version = self.current_verison.version + 1
    self.save!
    self.update_attribute(:current_version_id, version.id)
    version
  end

  def create_first_version!(attributes, user)
    version = self.versions.build(attributes)
    version.written_at = Time.now
    version.writer_id = user.id
    version.state ||= "Raw"
    version.version = 1
    self.save!
    self.update_attribute(:current_version_id, version.id)
    version
  end
end


class ArticlesController < ApplicationController
  def create
    @article = Article.new(params[:article])
    @article.reporter_id = current_user.id

    begin
      Article.transaction do
        @version = @article.create_version!(params[:version],
                                            current_user)
      end
    rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
      render :action => :index and return false
    end
    redirect_to article_path(@article)
  end
end


# after refactoring

class Article < ActiveRecord::Base64
  before_save :set_version
  before_save :update_related
  after_create :set_current_version_on_article

  private

  def set_version
    self.version = (self.current_version.version ? self.current_version.version : 0) + 1
  end

  def update_relateds
    unless self.versions.empty?
      self.current_version.relateds.each { |rel|
        rel.update_attribute(:current, false) }
    end
  end

  def set_current_version_on_article
    self.update_attribute(:current_version_id, self.id)
  end
end

class AddRawDefaultToState < ActiveRecord::Migration
  def self.up
    change_column_default :article_versions, :state, "Raw"
  end
  def self.down
    change_column_default :article_versions, :state, nil
  end
end


class ArticlesController < ApplicationController

  def create
    @article = Article.new(params[:article])
    @article.reporter_id = current_user.id
    @version = @article.versions.build(params[:version])
    @version.writer_id = current_user.id

    if @article.save!
      render :action => :index
     else
      redirect_to article_path(@article)
    end
  end

end
