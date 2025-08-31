#!/bin/bash -x

# -e: 失敗で終了
# -u: 未定義変数をエラー扱い
# -o pipefail: パイプ中のどれかが失敗しても拾う
set -euo pipefail

# MASで配布しないアプリはdeveloper certで署名すると、gatekeeperでも開くことが可能になる
# 以下の手順で証明書を作って署名につかう
# https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/MaintainingCertificates/MaintainingCertificates.html#//apple_ref/doc/uid/TP40012582-CH31-SW32

# entitlementsに設定できるkeyはここをみる
# https://developer.apple.com/library/content/documentation/Miscellaneous/Reference/EntitlementKeyReference/Chapters/EnablingAppSandbox.html

# codesignについて手動で行うにはMAS版の方法を参考にする
# https://electronjs.org/docs/tutorial/mac-app-store-submission-guide

# team idやentitlementなどを確認するにはcodesignコマンドを使う
# codesign -vv -d --entitlements :- ./out/release-app/Jasper.app

# fixme: electron v6.0.7ではapp-sandboxを有効にできず困っているが、解決策はまだない
# --entitlements, --entitlements-inheritを指定するとcodesign後にjasperが起動しない
# --ignoreを指定すると起動はするがapp-sandboxは有効にならない

export DEBUG=electron-osx-sign*

electron-osx-sign ./out/release-app/Jasper.app \
--platform=darwin \
--identity="Developer ID Application: Ryo Maruyama (G3Z4F76FBZ)" \
--type=distribution \
--hardened-runtime \
--entitlements="./misc/plist/notarization.plist" \
--entitlements-inherit="./misc/plist/notarization.plist" \
# --no-pre-auto-entitlements \
# --ignore="Jasper Helper .*" \
# --no-gatekeeper-assess \

# notarizeしてチケットを添付する
# https://kilianvalkhof.com/2019/electron/notarizing-your-electron-application/
# https://uechi.io/blog/sign-and-notarize-electron-app
# https://developer.apple.com/documentation/security/notarizing_your_app_before_distribution/customizing_the_notarization_workflow#3087720
node ./script/build-release/notarize.js
xcrun stapler staple ./out/release-app/Jasper.app
