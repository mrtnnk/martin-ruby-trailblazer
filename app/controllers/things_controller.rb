class Thing::Operation < Thing::Contract
  include ::Trailblazer::Operation

  # 1. in initialize, the twin data populates the contract
  #    that is correct as the twin might be an existing, already populated object
  #    and the incoming data is only a sub-set.
  # def initialize(twin)
  #   @twin = twin
  #   @contract= Thing::Contract.new(@twin) # Setup
  # end

  class JSON < self
    def deserialize(json) # an Operation's content subclass should always use the concept's representer.
      Thing::Representer.new(self).from_json(json)
    end
  end

  class Hash < self
    def deserialize(json)
      Thing::Representer.new(self).from_hash(json)
    end
  end


  include Trailblazer::Operation::Flow
  # DISCUSS: could also be separate class.


  class Form < Thing::Form # FIXME.
    include Trailblazer::Operation::Flow
  end
end




class ThingsController < ApplicationController
  def index
  end

  def new
    @form = Thing::Form.new(Thing::Twin.new)

  end

  def create
    # Thing::Operation::Create.for(
    #   # form: valid: redirect, invalid: render
    #   # json: valid: render, invalid: render something else
    #   )

    Thing::Endpoint::Create.new.call(self, params)
  end

  # has_cell :

  def show
    @thing = Thing::Twin.find(params[:id])
    rating  = Rating::Twin.new(thing: @thing) # Thing.ratings.build, or should that be handled by the form?
    @form   = Rating::Form.new(rating)

     # renders concept.
  end
  def form # TODO: this should happen in the cell-ajax.
    # DISCUSS: we could also think about hooking an Endpoint/Operation to a route that then renders the cell?
    # but, why? UI and API have different behaviour anyway.

    @thing = Thing::Twin.find(params[:id])
    # rating  = Rating::Twin.new(thing: @thing)

    # should be Operation::Create::Form or Form.create


    # everything below the line here is done in Rating::Operation::Create
    rating  = Rating::Twin.new

    @form = Rating::Operation::Form.new(rating)
    @form.flow(self, params[:rating])


    # @form   = Rating::Form.new(rating)

    # if @form.validate(params[:rating])
    #   @form.save
    #   return redirect_to thing_path(@thing.id)
    # end

    # render action: :show
  end
end
