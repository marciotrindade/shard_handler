require 'spec_helper'

RSpec.describe ShardHandler do
  describe '.current_shard and .current_shard= acessors' do
    it 'sets a shard name for the current thread' do
      described_class.current_shard = :shard1
      expect(described_class.current_shard).to be :shard1
    end

    context 'passing nil' do
      it 'sets current shard to nil' do
        described_class.current_shard = nil
        expect(described_class.current_shard).to be nil
      end
    end

    context 'passing a string' do
      it 'casts the value as symbol' do
        described_class.current_shard = 'shard1'
        expect(described_class.current_shard).to be :shard1
      end
    end
  end

  describe '.setup' do
    it 'initializes connection handlers cache' do
      expect_any_instance_of(ShardHandler::Cache)
        .to receive(:cache_connection_handlers)
      described_class.setup(double)
    end
  end

  describe '#current_connection_handler' do
    before do
      described_class.setup({
        "shard1" => {
          "adapter" => "postgresql",
          "encoding" => "unicode",
          "database" => "shard1",
          "username" => "postgres",
          "password" => nil
        }
      })
    end

    context 'current shard set' do
      it 'returns the current connection handler for the thread' do
        described_class.current_shard = :shard1
        expect(described_class.current_connection_handler)
          .to be_kind_of(ActiveRecord::ConnectionAdapters::ConnectionHandler)
      end
    end

    context 'current shard not set' do
      it 'returns nil' do
        described_class.current_shard = nil
        expect(described_class.current_connection_handler).to be nil
      end
    end
  end
end
