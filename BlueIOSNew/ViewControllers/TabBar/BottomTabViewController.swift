//
//  BottomTabViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit

class TabViewController: UITabBarController, UITabBarControllerDelegate {

    private var aTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        // Acesse a barra de abas da sua instância de UITabBarController
        self.tabBar.isTranslucent = true
        self.extendedLayoutIncludesOpaqueBars = true
        
        aTimer = Timer.scheduledTimer(withTimeInterval: 0.22, repeats: true){ t in
            if(Settings.initialized) {
                switch (Settings.has_cromo) {
                case 0:
                    self.viewControllers?.remove(at: 1)
                case 2:
                    self.viewControllers?.remove(at: 0)
                default:
                    break
                }
                self.aTimer?.invalidate()
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TabBarTransitionAnimator()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        aTimer?.invalidate()
    }
    
    
}

class TabBarTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3 // Defina a duração da animação
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to),
              let fromView = fromVC.view,
              let toView = toVC.view else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        // Defina a animação desejada
        toView.alpha = 0.0
        containerView.addSubview(toView)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromView.alpha = 0.0
            toView.alpha = 1.0
        }) { _ in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
