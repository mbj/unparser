RSpec.describe Unparser::Adamantium::Memory do
  describe '#fetch' do
    let(:events)  { []                         }
    let(:monitor) { instance_double(Monitor)   }
    let(:name)    { :some_name                 }
    let(:object)  { described_class.new(proxy) }
    let(:values)  { {}                         }
    let(:value_was_read) { -> {} }

    let(:block) do
      lambda do
        events << :block_call
        @counter += 1
      end
    end

    let(:proxy) do
      proxy  = instance_double(Hash)
      values = values()

      allow(proxy).to receive(:fetch) do |name, &block|
        events << :fetch
        values.fetch(name) do
          value_was_read.call
          block.call
        end
      end

      allow(proxy).to receive(:[]=) do |name, value|
        events << :set
        values[name] = value
      end

      proxy
    end


    def apply
      object.fetch(name, &block)
    end

    before do
      allow(Monitor).to receive_messages(new: monitor)

      allow(monitor).to receive(:synchronize) do |&block|
        events << :synchronize_start
        block.call.tap do
          events << :synchronize_end
        end
      end

      @counter = 0
    end

    shared_examples 'expected events' do
      it 'triggers expected events' do
        expect { apply }
          .to change(events, :to_a)
          .from([]).to(expected_events)
      end

      it 'returns expected value' do
        expect(apply).to be(1)
      end

      it 'creates frozen objects' do
        expect(object.frozen?).to be(true)
      end
    end

    context 'when value is present in memory' do
      let(:values)          { { name => 1 } }
      let(:expected_events) { %i[fetch] }

      include_examples 'expected events'
    end

    context 'when value is not present in memory initially' do
      let(:values) { {} }

      let(:expected_events) do
        %i[
          fetch
          synchronize_start
          fetch
          block_call
          set
          synchronize_end
        ]
      end

      include_examples 'expected events'

      context 'but is present inside the lock' do
        let(:value_was_read) { ->() { values[name] = 1 } }

        let(:expected_events) do
          %i[
            fetch
            synchronize_start
            fetch
            synchronize_end
          ]
        end

        include_examples 'expected events'
      end

      context 'and is re-read after initial generation' do
        def apply
          super()
          super()
        end

        let(:expected_events) do
          %i[
            fetch
            synchronize_start
            fetch
            block_call
            set
            synchronize_end
            fetch
          ]
        end

        include_examples 'expected events'
      end
    end
  end
end
