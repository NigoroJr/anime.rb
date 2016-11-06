require 'spec_helper'
require 'date'

describe Epitrack::Series do
  let(:name) { 'Foobar' }
  let(:history) { [
    [4, nil, nil],
    [5, '2016-10-21 23:42:12' , nil],
    [7, nil, '2016/8/21']
  ] }
  let(:properties) {
    {
      template: 'foo{}bar',
      current_ep: 5,
    }
  }

  it 'returns an Enumerator if no block is given to each' do
    s = Epitrack::Series.new(name, history, properties)
    expect(s.each).to be_an(Enumerator)
  end

  it 'returns the Episode instance of the given index' do
    s = Epitrack::Series.new(name, history, properties)
    expect(s[0].number).to equal(4)
  end

  it 'returns the correct total number of episodes' do
    s = Epitrack::Series.new(name, history, properties)
    expect(s.size).to equal(3)
  end

  it 'returns the Episode instance of the given episode' do
    s = Epitrack::Series.new(name, history, properties)
    expect(s.ep(7).number).to equal(7)
  end
end
