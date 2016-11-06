require 'spec_helper'

describe Epitrack::Parser do
  let(:fn_num_only) { %w( 01 12 03 24 ) }
  let(:fn_back) { %w( foo01 foo12 foo03 foo24 ) }
  let(:fn_mid) { %w( foo01bar foo12bar foo23bar ) }
  let(:fn_front) { %w( 01bar 12bar 23bar ) }
  let(:fn_num_front) { %w( 1280-04bar 1280-12bar 1280-23bar ) }
  let(:fn_num_back) { %w( 01bar1280 12bar1280 23bar1280 ) }

  context 'when there are multiple filenames given' do
    context 'number is at the back of filename' do
      it 'finds the template' do
        res, fst, lst = Epitrack::Parser.parse(fn_back)
        expect(res).to eq 'foo{}'
        expect(fst).to eq 1
        expect(lst).to eq 24
      end
    end

    context 'when number is in the middle of filename' do
      it 'finds the template' do
        res, fst, lst = Epitrack::Parser.parse(fn_mid)
        expect(res).to eq 'foo{}bar'
        expect(fst).to eq 1
        expect(lst).to eq 23
      end
    end

    context 'when number is at the front of filename' do
      it 'finds the template' do
        res, fst, lst = Epitrack::Parser.parse(fn_front)
        expect(res).to eq '{}bar'
        expect(fst).to eq 1
        expect(lst).to eq 23
      end
    end

    context 'when there is another number in front' do
      it 'finds the template' do
        res, fst, lst = Epitrack::Parser.parse(fn_num_front)
        expect(res).to eq '1280-{}bar'
        expect(fst).to eq 4
        expect(lst).to eq 23
      end
    end

    context 'when there is another number behind' do
      it 'finds the template' do
        res, fst, lst = Epitrack::Parser.parse(fn_num_back)
        expect(res).to eq '{}bar1280'
        expect(fst).to eq 1
        expect(lst).to eq 23
      end
    end
  end

  context 'when only one filename is given' do
    context 'number is at the back of filename' do
      it 'finds the template' do
        res, fst, lst = Epitrack::Parser.guess_template(fn_back.first)
        expect(res).to eq 'foo{}'
        expect(fst).to eq 1
        expect(lst).to eq 1
      end
    end

    context 'when number is in the middle of filename' do
      it 'finds the template' do
        res, fst, lst = Epitrack::Parser.guess_template(fn_mid.first)
        expect(res).to eq 'foo{}bar'
        expect(fst).to eq 1
        expect(lst).to eq 1
      end
    end

    context 'when number is at the front of filename' do
      it 'finds the template' do
        res, fst, lst = Epitrack::Parser.guess_template(fn_front.first)
        expect(res).to eq '{}bar'
        expect(fst).to eq 1
        expect(lst).to eq 1
      end
    end

    context 'when there is another number in front' do
      it 'finds the template' do
        res, fst, lst = Epitrack::Parser.guess_template(fn_num_front.first)
        expect(res).to eq '1280-{}bar'
        expect(fst).to eq 4
        expect(lst).to eq 4
      end
    end

    context 'when there is another number behind' do
      it 'finds the template' do
        res, fst, lst = Epitrack::Parser.guess_template(fn_num_back.first)
        expect(res).to eq '{}bar1280'
        expect(fst).to eq 1
        expect(lst).to eq 1
      end
    end
  end
end
