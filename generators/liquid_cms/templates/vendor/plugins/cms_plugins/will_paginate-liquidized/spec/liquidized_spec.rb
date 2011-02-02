require File.dirname(__FILE__) + '/spec_helper'

describe 'WillPaginate::Liquidized' do
  
  before(:each) do
    # setup
  end

  it "should return Collection Drop for collection to_liquid"
  #do
    #@collection.to_liquid.class.should eql(WillPaginate::Liquidized::CollectionDrop)
  #end
  
  it "should allow access to collection drop methods"
  # do
  #   [:current_page, :per_page, :total_entries, :total_pages, :offset, 
  #    :previous_page, :next_page, :empty?, :length ].each do |method|
  #      assert_nothing_raised { @blogs.send method }
  #   end
  #   assert_nothing_raised { @blogs.sort_by do 1 end }
  # end
  
  it "should allow array access to collection"
  # do
  #   assert_nothing_raised { assert_equal 1, @blogs[0] }  
  # end
  
end