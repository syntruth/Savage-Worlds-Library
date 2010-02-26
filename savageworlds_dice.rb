module SavageWorlds
  require "dicelib"
  include Dice
  include Roll

  # A Subclass of Roll::Roll to add a few helper methods.
  class SWRoll < Roll
    def initialize(dstr, do_single=true)
      super(dstr, do_single)
      @value = self.maximum()
    end

    def value
      return @value
    end

    def half_value
      return @value / 2
    end

    def to_s
      d = @dice_parts.dup()
      d[:num] = 0
      d[:explode] = 0
      return build_dice_string(d)
    end

  end

  # A hash that holds the allowed dice in SW (the keys) and their
  # associated roll instances (the values.) See the +dicelib+ for more
  # information in regards to the +Roll::Roll+ class.
  AllowedDice = {
    :d4  => SWRoll.new("d4e", true),
    :d6  => SWRoll.new("d6e", true),
    :d8  => SWRoll.new("d8e", true),
    :d10 => SWRoll.new("d10e", true),
    :d12 => SWRoll.new("d12e", true)
  }

  # Because Ruby doesn't guarantee Hash keys will stay
  # in order, we'll use this array instead!
  # TODO: Perhaps use +SortedSet+ here instead.
  AllowedDiceOrder = [:d4, :d6, :d8, :d10, :d12]

  # Sets the roll values for the Wild Die, No Trait, and the Wild Die
  # With No Trait.
  WildDie = SWRoll.new("d6e", true)
  NoTrait = SWRoll.new("d4-2e", true)
  WildDieNoTrait = SWRoll.new("d6-2e", true)

  # Compares two die values from AllowedDice, useable for
  # +sort+ _if_ you use it with a block. i.e.:
  #
  #   [:d6, :d10, :d8].sort do |d1, d2|
  #     compare_dice(d1, d2)
  #   end
  #
  #   => [:d6, :d8, :d10]
  def compare_dice(die1, die2)
    idx1 = AllowedDiceOrder.index(die1)
    idx2 = AllowedDiceOrder.index(die2)

    # This handles values -not- in AllowedDice
    idx1 = -1 if idx1.nil?
    idx2 = -1 if idx2.nil?

    return idx1 <=> idx2
  end

  # Used to sort an array of dice.
  # NOTE: Values -not- in AllowedDice end up at the front
  # of the array.
  def sort_dice(dice=[])
    return [] if dice.class != Array
    return dice.sort {|d1, d2| compare_dice(d1, d2) }
  end

end
