require 'spec_helper'

describe Differ::Diff do
  before(:each) do
    Differ.separator = nil
    @diff = Differ::Diff.new
  end

  describe '#to_s' do
    before(:each) do
      @format = Differ.format
    end

    it 'should concatenate the result list' do
      expect(Differ::Diff.new('a', 'b', 'c').to_s).to eq('abc')
    end

    it 'should concatenate without regard for the Differ.separator' do
      Differ.separator = '*'
      expect(Differ::Diff.new('a', 'b', 'c').to_s).to eq('abc')
    end

    it 'should delegate insertion changes to Differ#format' do
      pending("Don't know expectation incantation for working with attr_accessor")
      
      i = +'b' # <== WTF is this?
      expect(@format).to(receive(:call).once.with(i).and_return('!'))
      expect(Differ::Diff.new('a', i, 'c').to_s).to eq('a!c')
    end
  end

  describe '#format_as' do
    before(:each) do
      @change = +'b' # <== and WTF this?!
      Differ.format = Module.new { def self.call(_c)
                                     fail :error
                                   end }
      @format = Module.new { def self.call(_c); end }
    end

    it 'should delegate change formatting to the given format' do
      pending("Don't know expectation incantation for working with attr_accessor")
      expect(@format).to(receive(:call).once.with(@change).and_return('!'))
      expect(Differ::Diff.new('a', @change, 'c').format_as(@format)).to eq('a!c')
    end

    it 'should use Differ#format_for to grab the correct format' do
      expect(Differ).to(receive(:format_for).once.with(@format))
      Differ::Diff.new.format_as(@format)
    end
  end

  describe '#same' do
    it 'should append to the result list' do
      @diff.same('c')
      expect(@diff).to eq(Differ::Diff.new('c'))
    end

    it 'should concatenate its arguments' do
      @diff.same('a', 'b', 'c', 'd')
      expect(@diff).to eq(Differ::Diff.new('abcd'))
    end

    it 'should join its arguments with Differ.separator' do
      Differ.separator = '*'
      @diff.same(*'a*b*c*d'.split)
      expect(@diff).to eq(Differ::Diff.new('a*b*c*d'))
    end

    describe 'when the last result was a String' do
      before(:each) do
        @diff = Differ::Diff.new('a')
      end

      it 'should append to the last result' do
        @diff.same('b')
        expect(@diff).to eq(Differ::Diff.new('ab'))
      end

      it 'should join to the last result with Differ.separator' do
        Differ.separator = '*'
        @diff.same('b')
        expect(@diff).to eq(Differ::Diff.new('a*b'))
      end
    end

    describe 'when the last result was a change' do
      before(:each) do
        @diff = Differ::Diff.new('z' >> 'd')
      end

      it 'should append to the result list' do
        @diff.same('a')
        expect(@diff).to eq(Differ::Diff.new(('z' >> 'd'), 'a'))
      end

      it 'should prepend Differ.separator to the result' do
        Differ.separator = '*'
        @diff.same('a')
        expect(@diff).to eq(Differ::Diff.new(('z' >> 'd'), '*a'))
      end

      it 'should do nothing to a leading Differ.separator on the insert' do
        @diff = Differ::Diff.new('a', ('*-' >> '*+'))
        Differ.separator = '*'
        @diff.same('c')
        expect(@diff).to eq(Differ::Diff.new('a', ('*-' >> '*+'), '*c'))
      end
    end

    describe 'when the last result was just a delete' do
      before(:each) do
        @diff = Differ::Diff.new(-'z')
      end

      it 'should append to the result list' do
        @diff.same('a')
        expect(@diff).to eq(Differ::Diff.new(-'z', 'a'))
      end

      it 'should append Differ.separator to the previous result' do
        Differ.separator = '*'
        @diff.same('a')
        expect(@diff).to eq(Differ::Diff.new(-'z*', 'a'))
      end

      it 'should relocate a leading Differ.separator on the delete to the previous item' do
        @diff = Differ::Diff.new('a', -'*b')
        Differ.separator = '*'
        @diff.same('c')
        expect(@diff).to eq(Differ::Diff.new('a*', -'b*', 'c'))
      end
    end

    describe 'when the last result was just an insert' do
      before(:each) do
        @diff = Differ::Diff.new(+'z')
      end

      it 'should append to the result list' do
        @diff.same('a')
        expect(@diff).to eq(Differ::Diff.new(+'z', 'a'))
      end

      it 'should append Differ.separator to the previous result' do
        Differ.separator = '*'
        @diff.same('a')
        expect(@diff).to eq(Differ::Diff.new(+'z*', 'a'))
      end

      it 'should relocate a leading Differ.separator on the insert to the previous item' do
        @diff = Differ::Diff.new('a', +'*b')
        Differ.separator = '*'
        @diff.same('c')
        expect(@diff).to eq(Differ::Diff.new('a*', +'b*', 'c'))
      end
    end
  end

  describe '#delete' do
    it 'should append to the result list' do
      @diff.delete('c')
      expect(@diff).to eq(Differ::Diff.new(-'c'))
    end

    it 'should concatenate its arguments' do
      @diff.delete('a', 'b', 'c', 'd')
      expect(@diff).to eq(Differ::Diff.new(-'abcd'))
    end

    it 'should join its arguments with Differ.separator' do
      Differ.separator = '*'
      @diff.delete(*'a*b*c*d'.split)
      expect(@diff).to eq(Differ::Diff.new(-'a*b*c*d'))
    end

    describe 'when the last result was a Change' do
      describe '(delete)' do
        before(:each) do
          @diff = Differ::Diff.new(-'a')
        end

        it 'should append to the last result' do
          @diff.delete('b')
          expect(@diff).to eq(Differ::Diff.new(-'ab'))
        end

        it 'should join to the last result with Differ.separator' do
          Differ.separator = '*'
          @diff.delete('b')
          expect(@diff).to eq(Differ::Diff.new(-'a*b'))
        end
      end

      describe '(insert)' do
        before(:each) do
          @diff = Differ::Diff.new(+'a')
        end

        it 'should turn the insert into a change' do
          @diff.delete('b')
          expect(@diff).to eq(Differ::Diff.new('b' >> 'a'))
        end

        it 'should relocate a leading Differ.separator on the insert to the previous item' do
          @diff = Differ::Diff.new('a', +'*b')
          Differ.separator = '*'
          @diff.delete('z')
          expect(@diff).to eq(Differ::Diff.new('a*', ('z' >> 'b')))
        end
      end
    end

    describe 'when the last result was not a Change' do
      before(:each) do
        @diff = Differ::Diff.new('a')
      end

      it 'should append a Change to the result list' do
        @diff.delete('b')
        expect(@diff).to eq(Differ::Diff.new('a', -'b'))
      end

      it 'should prepend Differ.separator to the result' do
        Differ.separator = '*'
        @diff.delete('b')
        expect(@diff).to eq(Differ::Diff.new('a', -'*b'))
      end
    end
  end

  describe '#insert' do
    it 'should append to the result list' do
      @diff.insert('c')
      expect(@diff).to eq(Differ::Diff.new(+'c'))
    end

    it 'should concatenate its arguments' do
      @diff.insert('a', 'b', 'c', 'd')
      expect(@diff).to eq(Differ::Diff.new(+'abcd'))
    end

    it 'should join its arguments with Differ.separator' do
      Differ.separator = '*'
      @diff.insert(*'a*b*c*d'.split)
      expect(@diff).to eq(Differ::Diff.new(+'a*b*c*d'))
    end

    describe 'when the last result was a Change' do
      describe '(delete)' do
        before(:each) do
          @diff = Differ::Diff.new(-'b')
        end

        it "should not change the 'insert' portion of the last result" do
          @diff.insert('a')
          expect(@diff).to eq(Differ::Diff.new('b' >> 'a'))
        end

        it 'should relocate a leading Differ.separator on the delete to the previous item' do
          @diff = Differ::Diff.new('a', -'*b')
          Differ.separator = '*'
          @diff.insert('z')
          expect(@diff).to eq(Differ::Diff.new('a*', ('b' >> 'z')))
        end
      end

      describe '(insert)' do
        before(:each) do
          @diff = Differ::Diff.new(+'a')
        end

        it 'should append to the last result' do
          @diff.insert('b')
          expect(@diff).to eq(Differ::Diff.new(+'ab'))
        end

        it 'should join to the last result with Differ.separator' do
          Differ.separator = '*'
          @diff.insert('b')
          expect(@diff).to eq(Differ::Diff.new(+'a*b'))
        end
      end
    end

    describe 'when the last result was not a Change' do
      before(:each) do
        @diff = Differ::Diff.new('a')
      end

      it 'should append a Change to the result list' do
        @diff.insert('b')
        expect(@diff).to eq(Differ::Diff.new('a', +'b'))
      end

      it 'should prepend Differ.separator to the result' do
        Differ.separator = '*'
        @diff.insert('b')
        expect(@diff).to eq(Differ::Diff.new('a', +'*b'))
      end
    end
  end
end
