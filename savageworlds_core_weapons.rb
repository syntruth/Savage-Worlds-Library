module SavageWorlds

  # Melee Weapons
  MeleeWeapons = {
    :dagger => MeleeWeapon.new("dagger", :d4, :weight => 1, :cost => 25),

    :great_sword => MeleeWeapon.new("great sword", :d10, :weight => 12, 
      :cost => 400, :parry => -1, :notes => "2 hands"
    ),

    :flail => MeleeWeapon.new("flail", :d6, :weight => 8, :cost => 200,
      :notes => "ignores shield parry and cover bonus"
    ),

    :katana => MeleeWeapon.new("katana", "d6e+2", :weight => 6, :cost => 1000,
      :armor_piercing => 2
    ),

    :long_sword => MeleeWeapon.new("long sword", :d8, :weight => 8, 
      :cost => 300, :notes => "includes scimitars"
    ),

    :rapier => MeleeWeapon.new("rapier", :d4, :weight => 3, :cost => 150,
      :parry => 1
    ),

    :short_sword => MeleeWeapon.new("short sword", :d6, :weight => 4, 
      :cost => 200, :notes => "includes cavalry sabers."
    ),

    :axe => MeleeWeapon.new("axe", :d6, :weight => 2, :cost => 200),

    :battle_axe => MeleeWeapon.new("battle axe", :d8, :weight => 10, 
      :cost => 300
    ),

    :great_axe => MeleeWeapon.new("greate axe", :d10, :weight => 15,
      :cost => 500, :armor_piercing => 1, :parry => -1,
      :notes => "2 hands"
    ),

    :maul => MeleeWeapon.new("maul", :d8, :weight => 20, :cost => 400,
      :armor_piercing => 0, :parry => -1, 
      :notes => "AP 2 vs. rigid armor (plate mail), 2 hands"
    ),

    :warhammer => MeleeWeapon.new("warhammer", :d6, :weight => 8, :cost => 250,
      :armor_piercing => 0, :notes => "AP 1 vs rigit armor (plate mail)"
    ), 

    :halberd => MeleeWeapon.new("halberd", :d8, :weight => 15, :cost => 250,
      :reach => 1, :notes => "2 hands"
    ),

    :lance => MeleeWeapon.new("lance", :d8, :weight => 10, :cost => 300,
      :armor_piercing => 0, :reach => 2, :notes => "AP 2 when charging"
    ),

    :pike => MeleeWeapon.new("pike", :d8, :weight => 25, :cost => 400,
      :reach => 2, :notes => "2 hands"
    ),

    :staff => MeleeWeapon.new("staff", :d4, :weight => 8, :cost => 10,
      :parry => 1, :reach => 1, :notes => "2 hands"
    ),

    :spear => MeleeWeapon.new("spear", :d6, :weight => 5, :cost => 100,
      :parry => 1, :reach => 1, :notes => "2 hands"
    ),

    # Modern
    :bangstick => MeleeWeapon.new("bangstick", "3d6e", :weight => 2, 
      :cost => 5, :notes => "must be reloaded (1 action)"
    ),

    :bayonet => MeleeWeapon.new("bayonet", :d4, :weight => 1, :cost => 25),
    :bayonet_affixed => MeleeWeapon.new("bayonet (affixed)", :d6, 
      :cost => 25, :parry => 1, :reach => 1, :notes => "2 hands"
    ),

    :baton => MeleeWeapon.new("baton", :d4, :weight => 1, :cost => 10,
      :notes => "Carried by most law-enforcement officials"
    ),

    :chainsaw => MeleeWeapon.new("chainsaw", "2d6e+4", :weight => 20, 
      :cost => 200, 
      :notes => "A natural 1 on the Fighting die (regardless of the " +
        "Wild Die) hits the user instead"
    ),

    :switchblade => MeleeWeapon.new("switchblade", :d4, :weight => 1, 
      :cost => 10, :notes => "-2 to be Noticed if hidden"
    ),

    :survival_knife => MeleeWeapon.new("survival knife", :d4, :weight => 3,
      :cost => 50, :notes => "contains supplies that add +1 to Survival rolls"
    )
  }

  # Range Weapons
  RangeWeapons = {
    :bow => RangeWeapon.new("bow", "2d6e", :weight => 2, :cost => 250,
      :range => [12, 24, 48], :rate_of_fire => 1, :shots => 0,
      :minimum_strength => :d6
    )
                   
  }

end
