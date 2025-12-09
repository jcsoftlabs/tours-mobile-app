#!/usr/bin/env node
// Script pour ajouter des images aux établissements dans la base de données

const API_BASE_URL = 'http://localhost:3000/api';

const imageUrls = {
  'estab1': [ // Hotel Paradise
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&h=600&fit=crop&q=80',
    'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&h=600&fit=crop&q=80',
    'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&h=600&fit=crop&q=80'
  ],
  'estab2': [ // Le Bistrot Moderne
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&h=600&fit=crop&q=80',
    'https://images.unsplash.com/photo-1552566062-01b8c7f40d7d?w=800&h=600&fit=crop&q=80',
    'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&h=600&fit=crop&q=80'
  ]
};

async function updateEstablishmentImages() {
  console.log('🚀 Mise à jour des images des établissements...\n');

  for (const [establishmentId, images] of Object.entries(imageUrls)) {
    try {
      console.log(`📸 Ajout d'images pour l'établissement ${establishmentId}...`);
      
      const response = await fetch(`${API_BASE_URL}/establishments/${establishmentId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          images: images
        })
      });

      if (response.ok) {
        console.log(`✅ Images ajoutées avec succès pour ${establishmentId}`);
        console.log(`   ${images.length} image(s) ajoutée(s)\n`);
      } else {
        console.log(`❌ Erreur pour ${establishmentId}: ${response.status} ${response.statusText}\n`);
      }
    } catch (error) {
      console.log(`❌ Erreur lors de la mise à jour de ${establishmentId}:`, error.message);
    }
  }

  // Vérification
  console.log('🔍 Vérification des images ajoutées...');
  try {
    const response = await fetch(`${API_BASE_URL}/establishments`);
    if (response.ok) {
      const data = await response.json();
      data.data.forEach(establishment => {
        console.log(`- ${establishment.name}: ${establishment.images?.length || 0} image(s)`);
      });
    }
  } catch (error) {
    console.log('Erreur lors de la vérification:', error.message);
  }

  console.log('\n✨ Terminé !');
}

updateEstablishmentImages();