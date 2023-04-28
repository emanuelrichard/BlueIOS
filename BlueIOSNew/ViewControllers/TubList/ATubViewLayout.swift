//
//  ATubViewLayout.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

// Importa a biblioteca UIKit
import UIKit

// Declara o protocolo ATubLayoutDelegate
protocol ATubLayoutDelegate: AnyObject {
func collectionView(
_ collectionView: UICollectionView,
heightForCellAtIndexPath indexPath: IndexPath) -> CGFloat
}

// Declara a classe ATubViewLayout, que herda de UICollectionViewLayout
class ATubViewLayout: UICollectionViewLayout {
    // Declara a propriedade delegate como um ATubLayoutDelegate opcional
    weak var delegate: ATubLayoutDelegate?

    // Declara as propriedades numberOfColumns e cellPadding como constantes
    private let numberOfColumns = 2
    private let cellPadding: CGFloat = 4

    // Declara o array cache como um array de UICollectionViewLayoutAttributes vazio
    private var cache: [UICollectionViewLayoutAttributes] = []

    // Declara a propriedade contentHeight como um CGFloat inicializado com o valor zero
    private var contentHeight: CGFloat = 0

    // Calcula a propriedade contentWidth baseado na largura da collectionView
    private var contentWidth: CGFloat {
      guard let collectionView = collectionView else {
        return 0
      }
      let insets = collectionView.contentInset
      return collectionView.bounds.width - (insets.left + insets.right)
    }

    // Sobrescreve a propriedade collectionViewContentSize, que retorna o tamanho da coleção
    override var collectionViewContentSize: CGSize {
      return CGSize(width: contentWidth, height: contentHeight)
    }

    // Método prepare() é chamado sempre que a collectionView precisa atualizar o layout
    override func prepare() {
        // Limpa o array cache
        cache.removeAll()
        
        // Verifica se a collectionView existe
      guard
        let collectionView = collectionView
        else {
          return
      }
      
      // Calcula a largura de cada coluna
      let columnWidth = contentWidth / CGFloat(numberOfColumns)
      var xOffset: [CGFloat] = []
      // Cria um array com os valores de xOffset para cada coluna
      for column in 0..<numberOfColumns {
        xOffset.append(CGFloat(column) * columnWidth)
      }
      var column = 0
      var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
      // Loop através de todos os itens da collectionView na seção 0
      for item in 0..<collectionView.numberOfItems(inSection: 0) {
        let indexPath = IndexPath(item: item, section: 0)
          
        // Pergunta ao delegate a altura da célula para o item atual ou usa o valor padrão 190
        let photoHeight = delegate?.collectionView(
          collectionView,
          heightForCellAtIndexPath: indexPath) ?? 190
          
        // Calcula a altura da célula incluindo o padding superior e inferior
        let height = cellPadding * 2 + photoHeight
          
        // Calcula o frame da célula usando os valores de xOffset, yOffset, columnWidth e height
        let frame = CGRect(x: xOffset[column],
                           y: yOffset[column],
                           width: columnWidth,
                           height: height)
        
        // Adiciona o padding interno ao frame
        let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
          
        // Cria um UICollectionViewLayoutAttributes para a célula atual e define seu frame
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = insetFrame
        
        // Adiciona os atributos ao cache
        cache.append(attributes)
          
        // Atualiza a altura do conteúdo para incluir a nova célula
        contentHeight = max(contentHeight, frame.maxY)
        
        // Atualiza o yOffset da coluna atual
        yOffset[column] = yOffset[column] + height
        
        // Move para a próxima coluna
        column = column < (numberOfColumns - 1) ? (column + 1) : 0
      }
    }
    
    // Retorna os atributos de layout para os elementos que aparecem no retângulo especificado
    override func layoutAttributesForElements(in rect: CGRect)
        -> [UICollectionViewLayoutAttributes]? {

            var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
            
            // Loop através do cache e procurar por itens dentro do retângulo
            for attributes in cache {
                if attributes.frame.intersects(rect) {
                    visibleLayoutAttributes.append(attributes)
                }
            }
            return visibleLayoutAttributes
        }

        // Retorna os atributos de layout para o item no índice especificado do collectionView
        override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            return cache[indexPath.item]
        }
}
