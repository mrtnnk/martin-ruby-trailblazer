module Thing
  class Persistence < ActiveRecord::Base
    self.table_name = :rateables
  end

  class Twin < Disposable::Twin
    model Persistence

    property :name
    property :id # FIXME: why do i need this, again? should be infered.

    def persisted?
      model.persisted?
    end

    def self.model_name
      ::ActiveModel::Name.new(self, nil, "Thing") # Twin::ActiveModel should implement that. as a sustainable fix, we should simplify routing helpers.
    end

    def to_key
    #   return [1]
      model.to_key
    end

    # DISCUSS: this is used in simple_form_for [Rateable::Entity.new, @form] to compute nested URL. there must be a stupid respond_tp?(to_param) call in the URL helpers - remove that in Trailblazer.
    def to_param
      1
    end
  end

  class Form < Reform::Form
    property :name
    validates :name, presence: true

    model Thing
  end
end

class ThingsController < ApplicationController
  def index
  end

  def new
    @form = Thing::Form.new(Thing::Twin.new)
  end

  def create
    @form = Thing::Form.new(Thing::Twin.new)

    if @form.validate(params[:thing])
      @form.save
      return render text: "All good, #{@form.model.inspect}"
    end

    return render action: 'new'
  end
end