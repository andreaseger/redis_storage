require 'spec_helper'
class MockModel < RedisRecord::Model
  def self.attrs
    [:id,:body]
  end
  attr_accessor *attrs
  def self.db_key
    "mockmodel"
  end
end

describe RedisRecord::Model do
  let(:modelhash) do
    {'id'=>2,'body'=>"Lorem Ipsum"}
  end

  context 'class' do
    context '#new' do
      it 'should create accessors for all hash key/value pairs' do
        model = MockModel.new modelhash
        model.id.should == modelhash['id']
        model.body.should == modelhash['body']
      end
    end
    context '#build' do
      it 'should simply call new on MockModel' do
        MockModel.expects(:new)
        MockModel.build modelhash
      end
    end
    context '#create' do
      before(:each) do
        @model = MockModel.new modelhash
      end
      it 'should call new to create the accessors' do
        MockModel.expects(:new).returns(@model)
        MockModel.create modelhash
      end
      it 'should call save to save the record' do
        @model.expects(:save)
        MockModel.stubs(:new).returns(@model)
        MockModel.create modelhash
      end
    end
    context '#find_by_id' do
      let(:h) do
        [ {'id'=>1,'body'=>"Lorem"},
          {'id'=>2,'body'=>"Ipsum"},
          {'id'=>3,'body'=>"Dolor"},
          {'id'=>4,'body'=>"Sit Amet"}]
      end
      before(:each) do
        h.each do |e|
          MockModel.create e
        end
      end

      1.upto(4) do |i|
        it "should find record #{i} and create a new instance" do
          record = MockModel.find_by_id(i)
          record.id.should == i
          record.body.should == h[i-1]['body']
        end
      end
    end
  end

  context 'instance' do
    context '#save' do
      let(:model) do
        model = MockModel.new modelhash
      end
      it 'should create a redis entry' do
        model.save
        JSON.parse($db.get('mockmodel:2')).should == modelhash
      end
    end
  end
end
