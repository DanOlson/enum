# frozen_string_literal: true

require 'spec_helper'

class Book
  attr_reader :title

  def initialize(title) = @title = title
end

class Subject
  include Noomer

  Math = enum(Book)
  Literature = enum(Book)
  Science = enum(Book)
  PhyEd = enum

  ANSWER_TO_LIFE_UNIVERSE_AND_EVERYTHING = 42
end

class Coord
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
    freeze
  end

  def hash = [x, y].hash
  def eql?(other) = hash == other.hash
end

class WebEvent
  include Noomer

  PageLoad = enum
  PageUnload = enum
  Paste = enum(String)
  Click = enum(Coord)
end

class Color
  include Noomer

  Red = enum('#ff0000')
  Green = enum('#00ff00')
  Blue = enum('#0000ff')
end

RSpec.describe Noomer do
  describe '.enum' do
    it 'returns an subclass of the including class' do
      expect(WebEvent.enum).to be < WebEvent
    end
  end

  it 'must hold value of declared type' do
    expect { WebEvent::Click('here') }.to raise_error(ArgumentError)
  end

  it 'non-enum constants are work normally' do
    expect(Subject::ANSWER_TO_LIFE_UNIVERSE_AND_EVERYTHING).to eq(42)
  end

  describe 'integration' do
    let(:math_book) { Book.new('Beyond Algebra') }
    let(:lit_book) { Book.new('Beatniks Today') }
    let(:science_book) { Book.new('Wild Potions') }
    let(:subjects) do
      [
        Subject::Math(math_book),
        Subject::Literature(lit_book),
        Subject::Science(science_book),
        Subject::PhyEd()
      ]
    end

    it 'all variants are subclasses of the including class' do
      expect(subjects).to all be_a(Subject)
    end

    it 'provides enum behavior' do
      subjects.each do |sub|
        case sub
        when Subject::Math
          expect(sub.value).to eq(math_book)
        when Subject::Literature
          expect(sub.value).to eq(lit_book)
        when Subject::Science
          expect(sub.value).to eq(science_book)
        when Subject::PhyEd
          expect(sub.value).to eq(nil)
        end
      end
    end
  end

  it 'supports explicit discriminators' do
    red = Color::Red()
    green = Color::Green()
    blue = Color::Blue()
    expect(red.value).to eq('#ff0000')
    expect(green.value).to eq('#00ff00')
    expect(blue.value).to eq('#0000ff')
  end

  describe 'caching' do
    context 'variants with explicit discriminators' do
      it 'caches based on the discriminator' do
        expect(Color::Red()).to be(Color::Red())
      end
    end

    context 'variants with associated data' do
      it 'caches based on the associated data' do
        paste1 = WebEvent::Paste('copy')
        paste2 = WebEvent::Paste('copy')
        paste3 = WebEvent::Paste('paste')
        expect(paste1).to be(paste2)
        expect(paste2).to_not be(paste3)

        click1 = WebEvent::Click(Coord.new(0, 0))
        click2 = WebEvent::Click(Coord.new(0, 0))
        click3 = WebEvent::Click(Coord.new(0, 1))
        expect(click1).to be(click2)
        expect(click1).to_not be(click3)
      end
    end
  end
end
