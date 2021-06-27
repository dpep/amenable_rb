describe Amenable do
  describe '.wrap' do
    let(:fn) { proc {} }

    it 'requires a function-like input' do
      expect { Amenable.wrap(nil) }.to raise_error(ArgumentError)
    end

    it 'wraps a function with a function' do
      res = Amenable.wrap(fn)
      expect(res).to be_a Proc
      expect(res).not_to be fn
    end

    it 'returns a function that takes any input' do
      params = Amenable.wrap(fn).parameters.map &:first
      expect(params).to eq [ :rest, :keyrest, :block ]
    end
  end

  describe '.call' do
    let(:fn) { proc {|x, y = :y, a:, b: 2| [ [ x, y ], { a: a, b: b } ] } }

    it 'calls .wrap under the hood' do
      fn = proc {}
      expect(Amenable).to receive(:wrap).with(fn).and_call_original
      Amenable.call(fn)
    end

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

      expect {
        Amenable.call(fn, a: 1, b: 2)
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

      it 'fails without enough args' do
        expect {
          Amenable.call(fn, :x)
        }.to raise_error(ArgumentError)

        expect {
          Amenable.call(fn, a: 1)
        }.to raise_error(ArgumentError)
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
  end
end
