return {

	----------------------------------------------------------
	-- Abilityt/spellit, jne.
	----------------------------------------------------------

	fireball = {
		icon = "Skill_Icons/Fireball.png",
		itemLevel = 1,
		effect = "damage",
		attackType = "projectile",
		damageMin = 1,
		damageMax = 1,
		impactForce = 10,
		image = "Projectiles/proj9.png",
		range = 400,
		travelSpeed = 500,
		cooldown = 1000
	},

	trustyBow = {
		icon = "Gear_Icons/TrustyBow.png",
		itemLevel = 1,
		effect = "damage",
		attackType = "projectile",
		damageMin = 1,
		damageMax = 3,
		impactForce = 10,
		image = "Projectiles/proj12.png",
		range = 400,
		travelSpeed = 500,
		cooldown = 1000
	},

	mysticBow = {
		icon = "Gear_Icons/MysticBow.png",
		itemLevel = 1,
		effect = "damage",
		attackType = "projectile",
		damageMin = 5,
		damageMax = 10,
		impactForce = 10,
		image = "Projectiles/proj14.png",
		range = 400,
		travelSpeed = 500,
		cooldown = 1000
	},

	infernalCrossbow = {
		icon = "Gear_Icons/InfernalCrossbow.png",
		itemLevel = 1,
		effect = "damage",
		attackType = "projectile",
		damageMin = 5,
		damageMax = 10,
		impactForce = 10,
		image = "Projectiles/proj1.png",
		range = 400,
		travelSpeed = 500,
		cooldown = 1000
	},

	frostCircle = {
		icon = "Skill_Icons/FrostCircle.png",
		itemLevel = 1,
		effect = "damage",
		attackType = "onGround",
		damageMin = 1,
		damageMax = 1,
		impactForce = 5,
		-- image = "proj9.png",
		range = 100,
		cooldown = 2000,
		tickCount = 5,
		tickRate = 400,

	},

	dodge = {
		icon = "Skill_Icons/Dodge.png",
		range = 25,
		-- range = 11
		cooldown = 3000,
		duration = 400
	},

	heal = {
		icon = "Skill_Icons/Heal.png",
		effect = 5,
		range = 25,
		-- range = 11
		cooldown = 3000,
		duration = 400
	},

	spin = {
		icon = "Skill_Icons/PowerThrust.png",
		arch = 380,
		effect = "damage",
		damageMin = 1,
		damageMax = 2,
		duration = 400,
		cooldown = 300,
		impactForce = 15,
	},

	flurry = {
		icon = "Skill_Icons/ComboSlash.png",
		cooldown = 100,
		hitCount = 3,
		angleVariance = 20,
		hitDelay = 100
	},

	leap = {
		icon = "Skill_Icons/Leap.png",
		itemLevel = 1,
		effect = "damage",
		attackType = "onGround",
		damageMin = 1,
		damageMax = 1,
		impactForce = 5,
		-- image = "proj9.png",
		range = 100,
		cooldown = 2000,
		tickCount = 1,
		tickRate = 400,
	},

	shadowStrike = {
		icon = "Skill_Icons/ShadowStrike.png",
		duration = 1000,
		cooldown = 100,
		damageMin = 1,
		damageMax = 1,
		impactForce = 5,
		},

	----------------------------------------------------------
	-- Aseet
	----------------------------------------------------------

	trustysword = {
		icon = "Gear_Icons/TrustySword.png",
		arch = 120,
		effect = "damage",
		type = "weapon",
		damageMin = 1,
		damageMax = 3,
		duration = 250,
		cooldown = 300,
		impactForce = 6,
		image = "trustysword.png"
	},

	mysticsword = {
		icon = "Gear_Icons/MysticSword.png",
		arch = 120,
		effect = "damage",
		type = "weapon",
		damageMin = 5,
		damageMax = 10,
		duration = 350,
		cooldown = 350,
		impactForce = 6,
		image = "mysticsword.png"
	},

	infernalrapier = {
		icon = "Gear_Icons/InfernalRapier.png",
		arch = 120,
		effect = "damage",
		type = "weapon",
		damageMin = 10,
		damageMax = 20,
		duration = 450,
		cooldown = 450,
		impactForce = 6,
		image = "infernalrapier.png"
	},

	-- spear = {
	-- 	arch = 1,
	-- 	icon = "Gear_Icons/icon1.png",
	-- 	effect = "damage",
	-- 	type = "weapon",
	-- 	damageMin = 1,
	-- 	damageMax = 2,
	-- 	duration = 150,
	-- 	cooldown = 300,
	-- 	impactForce = 3,
	-- 	image = "tempSpear.png"
	-- },

	-- dagger = {
	-- 	image = "Gear_Icons/miekkatest.png"
	-- 	arch = 120,
	-- 	effect = "damage",
	-- 	type = "weapon",
	-- 	damageMin = 1,
	-- 	damageMax = 2,
	-- 	duration = 80,
	-- 	cooldown = 100,
	-- 	impactForce = 2,
	-- },

	----------------------------------------------------------
	-- Armorit, jne.
	----------------------------------------------------------

	enchantedHide = {
		type = "armor",
		icon = "Gear_Icons/EnchantedHides.png",
		intellect = 0,
		strength = 0,
		agility = 0,
		health = 0,
		movementSpeed = 0,
		armorSpell = 0,
		armorPhysical = 0,
	},

	enchantedPlate = {
		type = "armor",
		icon = "Gear_Icons/EnchantedPlate.png",
		intellect = 0,
		strength = 0,
		agility = 0,
		health = 0,
		movementSpeed = 0,
		armorSpell = 0,
		armorPhysical = 0,
	},

	enchantedRobes = {
		type = "armor",
		icon = "Gear_Icons/EnchantedRobes.png",
		intellect = 0,
		strength = 0,
		agility = 0,
		health = 0,
		movementSpeed = 0,
		armorSpell = 0,
		armorPhysical = 0,
	},

	forestersFur = {
		type = "armor",
		icon = "Gear_Icons/ForestersFur.png",
		intellect = 0,
		strength = 0,
		agility = 0,
		health = 0,
		movementSpeed = 0,
		armorSpell = 0,
		armorPhysical = 0,
	},

	forestersMail = {
		type = "armor",
		icon = "Gear_Icons/ForestersMail.png",
		intellect = 0,
		strength = 0,
		agility = 0,
		health = 0,
		movementSpeed = 0,
		armorSpell = 0,
		armorPhysical = 0,
	},

	forestersVestment = {
		type = "armor",
		icon = "Gear_Icons/ForestersVestment.png",
		intellect = 0,
		strength = 0,
		agility = 0,
		health = 0,
		movementSpeed = 0,
		armorSpell = 0,
		armorPhysical = 0,
	},

	hidesoftheSwamp = {
		type = "armor",
		icon = "Gear_Icons/HidesoftheSwamp.png",
		intellect = 0,
		strength = 0,
		agility = 0,
		health = 0,
		movementSpeed = 0,
		armorSpell = 0,
		armorPhysical = 0,
	},

	plateoftheSwamp = {
		type = "armor",
		icon = "Gear_Icons/PlateoftheSwamp.png",
		intellect = 0,
		strength = 0,
		agility = 0,
		health = 0,
		movementSpeed = 0,
		armorSpell = 0,
		armorPhysical = 0,
	},

	robesoftheSwamp = {
		type = "armor",
		icon = "Gear_Icons/RobesoftheSwamp.png",
		intellect = 0,
		strength = 0,
		agility = 0,
		health = 0,
		movementSpeed = 0,
		armorSpell = 0,
		armorPhysical = 0,
	},

	----------------------------------------------------------
	-- Trinketit, jne.
	----------------------------------------------------------



}