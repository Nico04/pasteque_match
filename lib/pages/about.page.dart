import 'package:flutter/material.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/utils/extensions.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: 'À propos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tutotiel',
            style: context.textTheme.titleMedium,
          ),
          AppResources.spacerSmall,
          const Text(
'''Bienvenue sur l’application ludique et pratique qui va vous permettre de trouver LE prénom de votre enfant !
Déplacez la carte à droite si le prénom vous plait, à gauche s’il ne vous plaît pas. 
Vous pouvez définir des filtres pour affiner votre recherche.
Retrouvez sur votre profil une liste de tous les prénoms pour lesquels vous avez déjà voté.
Connectez-vous à votre partenaire via un système de QR code très simple et commencez à matcher en couple.
Si vous et votre partenaire aimez le même prénom, alors : “it’s a match!” (ils apparaîtront dans la liste des matches).

Quelques petites précisions :
- Les prénoms sont regroupés par phonétique (cela vous fait gagner du temps et vous propose directement des orthographes alternatives). Pensez à cliquer sur la carte pour afficher tous les prénoms associés (il peut y en avoir des masculins et des féminins).
- Une fois la carte ouverte avec la liste des prénoms, vous pouvez cliquer sur chacune des orthographes existantes afin de découvrir les statistiques (combien de fois il a été donné et en quelle année)''',
          ),

          AppResources.spacerExtraLarge,
          Text(
            'Qui sommes-nous ?',
            style: context.textTheme.titleMedium,
          ),
          AppResources.spacerSmall,
          const Text(
'''Lorsque nous attendions notre premier enfant, nous avons cherché différents supports pour nous aider dans la recherche de prénom. Mais aucun ne nous a vraiment satisfait. Nous cherchions une solution à la fois ludique et très claire, capable de nous aider réellement dans cette démarche. Et les solutions proposées étaient souvent trop succinctes, chargées en publicités ou payantes…
C’est ainsi qu’est née l’idée de Pastèque Match : une application à la fois complète, gratuite et open-source.''',
          ),

          AppResources.spacerExtraLarge,
          Text(
            'Pourquoi Pastèque Match ?',
            style: context.textTheme.titleMedium,
          ),
          AppResources.spacerSmall,
          const Text(
'''Sur de nombreuses applications de grossesse, le bébé à naître est comparé à des fruits et légumes en fonction de l’évolution de sa taille et de son poids. En fin de grossesse, c’est généralement la pastèque qui est choisie ! Et les matches, ce sont les prénoms que vous allez aimer en commun avec votre partenaire.''',
          ),

          AppResources.spacerExtraLarge,
          Text(
            'Notre démarche',
            style: context.textTheme.titleMedium,
          ),
          AppResources.spacerSmall,
          const Text(
'''Nous avons trouvé sur le site de l’INSEE la liste de tous les prénoms donnés en France depuis 1900. C’est de cette base que nous sommes partis pour créer l’application. Cela nous permet également de vous présenter les statistiques liées à chaque prénom (combien de fois il a été donné pour chaque année).
A partir de cette liste, nous avons fait tout un travail de regroupement par phonétique car nous avons rapidement découvert que de nombreux prénoms apparaissaient plusieurs fois sous des orthographes alternatives : nous avons fait le choix de les regrouper sur une seule et même “carte”. C’est pour cela que vous pouvez parfois trouver des versions féminines et masculines d’un prénom sur une même carte : ils se prononcent de la même manière.''',
          ),
        ],

      ),
    );
  }
}
