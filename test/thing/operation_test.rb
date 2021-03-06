require 'test_helper'

class ThingOperationTest < MiniTest::Spec

  # new user
  it do
    thing = Thing::Create[thing: {name: "Cells", authors: ["email" => "nick@trb.org", "id" => ""]}].model

    # for API, existing author are automatically associated.
    user = User.find_by_email("nick@trb.org")
    thing.authors.must_equal [user]
    User.count.must_equal 1 # TODO: this shouldn't be here.
  end

  # blank user gets ignored
  it do
    thing = Thing::Create[thing: {name: "Cells", authors: ["email" => ""]}].model

    thing.authors.must_equal []
    User.count.must_equal 0 # TODO: this shouldn't be here.
  end

  # new user, email invalid
  it do
    exc = assert_raises Trailblazer::Operation::InvalidContract do
      thing = Thing::Create[thing: {name: "Cells", authors: ["email" => "argh"]}].model
    end
    exc.message.must_equal "{:\"authors.email\"=>[\"wrong format\"]}"
  end

  # existing user, email already taken!
  it do
    user  = User::Create[name: "Nick", email: "nick@trb.org"]

    exc = assert_raises Trailblazer::Operation::InvalidContract do
      thing = Thing::Create[thing:{name: "Cells", authors: ["email" => "nick@trb.org"]}].model
    end
    exc.message.must_equal "{:\"authors.email\"=>[\"has already been taken\"]}"
  end

  # user-id for existing user
  it do
    user  = User::Create[name: "Nick", email: "nick@trb.org"]
    thing = Thing::Create[thing: {name: "Cells", authors: ["id" => user.id]}].model

    thing.authors.must_equal [user]
  end

  # user-id AND invalid email for existing user, email gets ignored.
  it do
    user  = User::Create[name: "Nick", email: "nick@trb.org"]
    thing = Thing::Create[thing: {name: "Cells", authors: ["id" => user.id, "email" => "rubbish"]}].model

    thing.authors.must_equal [user]
    user.email.must_equal "nick@trb.org"
  end

  # user-id but not existing.
  it do
    # we could also catch this and mark form as invalid?
    assert_raises ActiveRecord::RecordNotFound do
      thing = Thing::Create[thing: {name: "Cells", authors: ["id" => 1]}].model
    end
  end
end