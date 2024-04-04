describe Amenable do
  describe '.call' do
    let(:fn) { proc {|x, y = :y, a:, b: 2| [ [ x, y ], { a: a, b: b } ] } }

    it 'takes args and kwargs as expected' do
      expect(fn).to receive(:call).with(:x, :y, a: 1, b: 2)
      Amenable.call(fn, :x, :y, a: 1, b: 2)
    end

    it 'removes excessive parameters' do
      expect(fn).to receive(:call).with(:x, :y, a: 1, b: 2)
      Amenable.call(fn, :x, :y, :z, a: 1, b: 2, c: 3)
    end

    it 'works with splat operator' do
      args = [ :x, :y, :z ]
      kwargs = { a: 1, b: 2, c: 3 }

      expect(fn).to receive(:call).with(:x, :y, a: 1, b: 2)
      Amenable.call(fn, *args, **kwargs)
    end

    it 'works with default args' do
      expect(fn).to receive(:call).with(:x, a: 1).and_call_original

      expect(Amenable.call(fn, :x, a: 1)).to eq([
        [ :x, :y ],
        { a: 1, b: 2 },
      ])
    end

    it 'works with missing args' do
      # positional args are technically not required
      
      expect(Amenable.call(fn, a: 1, b: 2)).to eq([
        [ nil, :y ],
        { a: 1, b: 2 },
      ])
    end

    it 'raises if required arguments are not passed' do
      expect {
        Amenable.call(fn, :x)
      }.to raise_error(ArgumentError)

      expect {
        Amenable.call(fn, :x, :y)
      }.to raise_error(ArgumentError)

      expect {
        Amenable.call(fn, :x, :y, b: 2)
      }.to raise_error(ArgumentError)
    end

    context 'with var args' do
      let(:fn) { proc {|x, *z, a:, **c| [ x, z, a, c ] } }

      it 'works with just enough args' do
        expect(fn).to receive(:call).with(:x, a: 1).and_call_original

        expect(Amenable.call(fn, :x, a: 1)).to eq([
          :x, [], 1, {},
        ])
      end

      it 'works with missing args' do
        expect(Amenable.call(fn, a: 1)).to eq([
          nil, [], 1, {},
        ])
      end

      it 'fails on missing kwargs' do
        expect { Amenable.call }.to raise_error(ArgumentError)
      end

      it 'passes through all args' do
        expect(Amenable.call(fn, :x, :y, :z, a: 1, b: 2, c: 3)).to eq([
          :x, [ :y, :z ], 1, { b: 2, c: 3 },
        ])
      end
    end

    context 'with a method' do
      before do
        def test_fn(x, a:, &block)
          [ x, a, block ]
        end
      end

      it 'works all the same' do
        test_block = proc {}

        expect(Amenable.call(method(:test_fn), :x, a: 1, &test_block)).to eq([
          :x, 1, test_block
        ])
      end
    end

    context 'with a method that does not take params' do
      before do
        def test_fn; end
      end

      it 'works without args' do
        expect(Amenable.call(method(:test_fn))).to be_nil
      end

      it 'works with args' do
        expect(Amenable.call(method(:test_fn), :x, :y)).to be_nil
      end

      it 'works with kwargs' do
        expect(Amenable.call(method(:test_fn), a: 1, b: 2)).to be_nil
      end
    end

    context 'with a method that only takes args' do
      before do
        def test_fn(arg)
          arg
        end
      end

      it 'fails without args' do
        expect {
          Amenable.call(method(:test_fn))
        }.to raise_error(ArgumentError)
      end

      it 'works with args' do
        expect(Amenable.call(method(:test_fn), :x, :y)).to be :x
      end

      it 'works with kwargs' do
        expect(Amenable.call(method(:test_fn), :x, a: 1, b: 2)).to be :x
      end
    end

    context 'with a method that only takes varargs' do
      before do
        def test_fn(*args)
          args
        end
      end

      it 'works without args' do
        expect(Amenable.call(method(:test_fn))).to eq []
      end

      it 'works with args' do
        expect(Amenable.call(method(:test_fn), :x, :y)).to eq [ :x, :y ]
      end

      it 'works with kwargs' do
        expect(Amenable.call(method(:test_fn), :x, :y, a: 1, b: 2)).to eq [ :x, :y ]
      end
    end

    context 'with a method that only takes keywords' do
      before do
        def test_fn(a:)
          a
        end
      end

      it 'fails without args' do
        expect {
          Amenable.call(method(:test_fn))
        }.to raise_error(ArgumentError)
      end

      it 'works with args' do
        expect(Amenable.call(method(:test_fn), :x, a: 1)).to be 1
      end

      it 'works with kwargs' do
        expect(Amenable.call(method(:test_fn), a: 1, b: 2)).to be 1
      end
    end

    it 'requires a Method or Proc' do
      expect {
        Amenable.call(:foo)
      }.to raise_error(ArgumentError)
    end
  end
end
