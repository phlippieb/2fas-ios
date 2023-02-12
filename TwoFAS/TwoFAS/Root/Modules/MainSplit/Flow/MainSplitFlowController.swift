//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2023 Two Factor Authentication Service, Inc.
//  Contributed by Zbigniew Cisiński. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <https://www.gnu.org/licenses/>
//

import UIKit

protocol MainSplitFlowControllerParent: AnyObject {
    func navigationSwitchedToTokens()
    func navigationSwitchedToSettings()
}

protocol MainSplitFlowControlling: AnyObject {
    func toInitialConfiguration()
}

final class MainSplitFlowController: FlowController {
    private weak var parent: MainSplitFlowControllerParent?
    
    static func showAsRoot(
        in viewController: MainViewController,
        parent: MainSplitFlowControllerParent
    ) {
        let view = MainSplitViewController()
        let flowController = MainSplitFlowController(viewController: view)
        flowController.parent = parent
        
        let interactor = InteractorFactory.shared.mainSplitModuleInteractor()

        let presenter = MainSplitPresenter(
            flowController: flowController,
            interactor: interactor
        )
        view.presenter = presenter
        presenter.view = view

        viewController.addChild(view)
        view.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.view.addSubview(view.view)
        view.didMove(toParent: viewController)
        viewController.splitView = view
    }
}

extension MainSplitFlowController {
    var viewController: MainSplitViewController { _viewController as! MainSplitViewController }
}

extension MainSplitFlowController: MainSplitFlowControlling {
    func toInitialConfiguration() {
        MainTabFlowController.insertAsCompact(into: viewController.split, parent: self)
        MainMenuFlowController.showAsRoot(in: viewController.navigationNavi, parent: self)
    }
}

extension MainSplitFlowController: MainTabFlowControllerParent {
    func tabNavigatedToViewPath(_ viewPath: ViewPath) {
        viewController.presenter.handlePathWasUpdated(to: viewPath)
    }
    
    func tabReady() {
        // Check if needed
    }
    
    func tabToTokens() {
        parent?.navigationSwitchedToTokens()
    }
}

extension MainSplitFlowController: MainMenuFlowControllerParent {
    func mainMenuToMain() {
        viewController.presenter.handlePathWasUpdated(to: .main)
        TokensPlainFlowController.showAsRoot(in: viewController.contentNavi, parent: self)
        parent?.navigationSwitchedToTokens()
    }
    
    func mainMenuToSettings() {
        // TODO: Navigate to subsection of Settings
        viewController.presenter.handlePathWasUpdated(to: .news)
        SettingsFlowController.showAsRoot(in: viewController.contentNavi, parent: self)
    }
    
    func mainMenuToNews() {
        viewController.presenter.handlePathWasUpdated(to: .news)
        NewsFlowController.showAsRoot(in: viewController.contentNavi, parent: self)
    }
}

extension MainSplitFlowController: TokensPlainFlowControllerParent {
    func tokensSwitchToTokensTab() {
        parent?.navigationSwitchedToTokens()
    }
}

extension MainSplitFlowController: SettingsFlowControllerParent {
    func settingsToUpdateCurrentPosition(_ viewPath: ViewPath.Settings?) {
        viewController.presenter.handlePathWasUpdated(to: .settings(option: viewPath))
    }
}

extension MainSplitFlowController: NewsFlowControllerParent {}
