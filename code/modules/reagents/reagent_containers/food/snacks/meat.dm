/obj/item/weapon/reagent_containers/food/snacks/meat
	name = "meat"
	desc = "A slab of meat."
	icon_state = "meat"
	health = 180
	filling_color = "#FF1C1C"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meat/atom_init()
	. = ..()
	reagents.add_reagent("protein", 3)

/obj/item/weapon/reagent_containers/food/snacks/meat/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/kitchenknife))
		new /obj/item/weapon/reagent_containers/food/snacks/rawcutlet(src)
		new /obj/item/weapon/reagent_containers/food/snacks/rawcutlet(src)
		new /obj/item/weapon/reagent_containers/food/snacks/rawcutlet(src)
		to_chat(user, "You cut the meat in thin strips.")
		qdel(src)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh
	name = "synthetic meat"
	desc = "A synthetic slab of flesh."

/obj/item/weapon/reagent_containers/food/snacks/meat/human
	name = "meat"
	var/subjectname = ""
	var/subjectjob = null

/obj/item/weapon/reagent_containers/food/snacks/meat/slab/meatproduct
	name = "meat product"
	desc = "A slab of station reclaimed and chemically processed meat product."

/obj/item/weapon/reagent_containers/food/snacks/meat/monkey
	//same as plain meat

/obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	name = "meat"
	desc = "Tastes like... something korean..."

/obj/item/weapon/reagent_containers/food/snacks/meat/pug
	name = "meat"
	desc = "Tastes like... uhhhh..."

/obj/item/weapon/reagent_containers/food/snacks/meat/ham
	name = "Ham"
	desc = "Taste like bacon."

/obj/item/weapon/reagent_containers/food/snacks/meat/meatwheat
	name = "meatwheat clump"
	desc = "This doesn't look like meat, but your standards aren't <i>that</i> high to begin with."
	filling_color = rgb(150, 0, 0)
	icon_state = "meatwheat_clump"
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/meat/meatwheat/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("vitamin", 2)
	reagents.add_reagent("blood", 5)