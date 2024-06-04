return {

     playerFilter = { categoryBits=1, maskBits=26 },
     npcFilter = { categoryBits=2, maskBits=23 },
     playerAttackFilter = { categoryBits=4, maskBits=18 },
     npcAttackFilter = { categoryBits=8, maskBits=17 },
     terrainFilter = { categoryBits=16, maskBits=127 },
     -- jumpFilter estää ettei pelaaja pysty hyppäämään seinien yli.
     jumpFilter = { categoryBits=64, maskBits=16 },

     -- Debuggaukseen: viholliset ei osu pelaajaan.
     playerInvulnerable = { categoryBits=32, maskBits=16 },

}