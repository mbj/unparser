require File.expand_path('../../spec_helper', __FILE__)

describe "Splat operator" do
  describe "used to assign a splatted object to an object" do
    ruby_version_is ""..."1.9" do
      it "assigns nil when the splatted object is nil" do
        a = *nil; a.should == nil
      end

      it "assigns nil when the splatted object is an empty array" do
        a = *[]; a.should == nil
      end

      it "assigns the splatted object when the splatted object doesn't respond to to_ary" do
        a = *1; a.should == 1
      end

      it "assigns the first element of the returned value of to_ary when the splatted object responds to to_ary and it has one element" do
        o = mock(Object)
        o.should_receive(:to_ary).once.and_return(["foo"])
        a = *o; a.should == "foo"
      end

      it "assigns nil when the content of the splatted array is nil" do
        a = *[nil]; a.should == nil
      end

      it "assigns an empty array when the content of the splatted array is an empty array" do
        a = *[[]]; a.should == []
      end

      it "assigns nil when the content of the splatted array is an empty splatted array" do
        a = *[*[]]; a.should == nil
      end

      it "assign the content of the second splatted array when the splatted array contains a splatted array with one element" do
        a = *[*[1]]; a.should == 1
      end

    end

    ruby_version_is "1.9" do
      it "assigns an empty array when the splatted object is nil" do
        a = *nil; a.should == []
      end

      it "assigns an empty array when the splatted object is an empty array" do
        a = *[]; a.should == []
      end

      it "assigns the splatted object contained into an array when the splatted object doesn't respond to to_a" do
        a = *1; a.should == [1]
      end

      it "assigns the splatted object contained into an array when the splatted object is a result of 'obj || []'" do
        a = *(1 || []); a.should == [1]
      end

      it "assigns the returned value of to_a when the splatted object responds to to_a" do
        o = mock(Object)
        o.should_receive(:to_a).once.and_return(["foo"])
        a = *o; a.should == ["foo"]
      end

      it "assigns the object in a new array when it responds to to_a but to_a returns nil" do
        o = mock(Object)
        o.should_receive(:to_a).once.and_return(nil)
        a = *o; a.should == [o]
      end

      it "assigns an array with nil object if the content of the splatted array is nil" do
        a = *[nil]; a.should == [nil]
      end

      it "assings an array with an empty array when the splatted array contains an empty array" do
        a = *[[]]; a.should == [[]]
      end

      it "assigns an empty array when the content of the splatted array is an empty splatted array" do
        a = *[*[]]; a.should == []
      end

      it "assigns the second array when the content of the splatted array is a non empty splatted array" do
        a = *[*[1]]; a.should == [1]
      end
    end

    it "assigns the second array when the splatted array contains a splatted array with more than one element" do
      a = *[*[1, 2]]; a.should == [1, 2]
    end
  end

  describe "used to assign an object to a splatted reference" do
    it "assigns an array with a nil object when the object is nil" do
      *a = nil; a.should == [nil]
    end

    it "assigns an array containing the object when the object is not an array" do
      *a = 1; a.should == [1]
    end

    ruby_version_is ""..."1.9" do
      it "assigns an array wrapping the object when the object is not an splatted array" do
        *a = []; a.should == [[]]
        *a = [1]; a.should == [[1]]
        *a = [nil]; a.should == [[nil]]
        *a = [1,2]; a.should == [[1,2]]
      end

      it "assigns an array containing another array when the object is an array that contains an splatted array" do
        *a = [*[]]; a.should == [[]]
        *a = [*[1]]; a.should == [[1]]
        *a = [*[1,2]]; a.should == [[1,2]]
      end
    end

    ruby_version_is "1.9" do
      it "assigns the object when the object is an array" do
        *a = []; a.should == []
        *a = [1]; a.should == [1]
        *a = [nil]; a.should == [nil]
        *a = [1,2]; a.should == [1,2]
      end

      it "assigns the splatted array when the object is an array that contains an splatted array" do
        *a = [*[]]; a.should == []
        *a = [*[1]]; a.should == [1]
        *a = [*[1,2]]; a.should == [1,2]
      end
    end
  end
end
