require 'spec_helper'
class MockModel < RedisStorage::Model
  def self.attrs
    [:body, :title]
  end
  attr_accessor *attrs
end

describe RedisStorage::Model do
  it_should_behave_like "ActiveModel"
  let(:modelhash) do
    {'body'=>"Lorem Ipsum", 'title' => "some test"}
  end

  context 'class' do
    it 'should have a db_key with the name of the class' do
      MockModel.db_key.should eq('mockmodel')
    end
    context '#build' do
      it 'should simply call new on MockModel' do
        MockModel.expects(:new)
        MockModel.build modelhash
      end
      it 'should create accessors for all hash key/value pairs' do
        model = MockModel.build modelhash
        model.body.should == modelhash['body']
        model.title.should == modelhash['title']
      end
    end
    context '#create' do
      before(:each) do
        @model = MockModel.build modelhash
      end
      it 'should call new to create the accessors' do
        MockModel.expects(:build).returns(@model)
        MockModel.create modelhash
      end
      it 'should call save to save the record' do
        @model.expects(:save)
        MockModel.stubs(:build).returns(@model)
        MockModel.create modelhash
      end
    end
    context '#find' do
      let(:h) do
        [ {'body' =>"Lorem Ipsum", 'title' => "first test"},
          {'body' =>"Dolor Sit", 'title' => "second test"},
          {'body' =>"Amet consetetur", 'title' => "third test"},
          {'body' =>"sadipscing elitr", 'title' => "forth test"}]
      end
      before(:each) do
        h.each do |e|
          MockModel.create e
        end
      end

      context '#find_by_id' do
        1.upto(4) do |i|
          it "should find record #{i} and create a new instance" do
            record = MockModel.find_by_id(i)
            record.id.should == i
            record.body.should == h[i-1]['body']
            record.title.should == h[i-1]['title']
          end
        end
      end
      context '#all' do
        it 'should return all entries' do
          records = MockModel.all
          records.size.should eq(4)
        end
        it 'should return an Array with all entries' do
          records = MockModel.all
          records.each do |m|
            i = m.id
            m.body.should eq(h[i-1]['body'])
            m.title.should eq(h[i-1]['title'])
          end
        end
      end
    end
  end

  context 'instance' do
    let(:model) do
      model = MockModel.build modelhash
    end
    context '#persisted?' do
      it 'should be false if it did not get saved yet' do
        model.persisted?.should be_false
      end
      it 'should be true if the model got saved' do
        model.save
        model.persisted?.should be_true
      end
    end
    context '#save' do
      it 'should be valid to save the model' do
        model.stubs(:valid? => true)
        model.save.should_not be_nil
      end
      it 'should not save the model if its invalid' do
        model.stubs(:valid? => false)
        model.save.should be_nil
      end
      it 'should create a redis entry' do
        id = model.save
        JSON.parse($db.get("mockmodel:#{id}")).should == modelhash.merge('id'=>id)
      end
      it 'should add the id to the persisted set in redis' do
        id = model.save
        $db.sismember("mockmodel:persisted", id).should be_true
      end
    end
    context '#delete!' do
      it 'should return false if the object is not persisted' do
        model.stubs(:persisted? => false)
        model.delete!.should be_false
      end
      it 'should return true if the object was persisted' do
        model.stubs(:persisted? => true)
        model.delete!.should be_true
      end
      it 'should remove the key from redis' do
        id=model.save
        model.delete!
        $db.get("mockmodel:#{id}").should be_nil
      end
      it 'should remove the id from the persisted set in redis' do
        id=model.save
        model.delete!
        $db.sismember("mockmodel:persisted", id).should be_false
      end
    end

    #context '#dirty' do
    #  it 'should be true till first saved' do
    #    model.changed?.should be_true
    #  end
    #  it 'should be false after saving' do
    #    model.save
    #    model.changed?.should be_false
    #  end
    #  it 'should be true if something got changed since last save' do
    #    model.save
    #    model.changed?.should be_false
    #    model.body = 'lorem ipsum'
    #    model.changed?.should be_true
    #  end
    #end
  end
end
