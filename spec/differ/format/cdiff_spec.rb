require 'spec_helper'
require 'differ/format/cdiff'

describe Differ::Format::CDIFF do
  it 'should format inserts well' do
    @expected = '<ins class="differ">SAMPLE</ins>'
    expect(Differ::Format::CDIFF.call(+'SAMPLE')).to(eq(@expected))
  end

  it 'should format inserts with linebreaks well' do
    @expected =<<-EOL
<ins class="differ">SAMPLE</ins>
<br class="cdiff_linebreak" />
<ins class="differ">Food</ins>
EOL
    expect(Differ::Format::CDIFF.call(+"SAMPLE\r\nFood")).to(eq(@expected.chop))

  end

  it 'should format deletes well' do
    @expected = '<del class="differ">SAMPLE</del>'
    expect(Differ::Format::CDIFF.call(-'SAMPLE')).to(eq(@expected))
  end

  it 'should format changes well' do
    @expected = '<del class="differ">THEN</del><ins class="differ">NOW</ins>'
    expect(Differ::Format::CDIFF.call(
      Differ::Change.new(delete: 'THEN', insert: 'NOW')
    )).to(eq(@expected))
  end

  it 'should include unchanged content' do
    Differ.format = Differ::Format::CDIFF
    c = "this is\nthe dawning of\nthe age of Aquarius! Rejoice"
    d = "this is\nthe dawning of\nthe age of the machines! Rejoice"
    expect(Differ.diff(d, c, /([\n ])/).to_s).to(
      eq("this is
the dawning of
the age of <del class=\"differ\">Aquarius!</del><ins class=\"differ\">the</ins> <ins class=\"differ\">machines! </ins>Rejoice"))

  end
end
