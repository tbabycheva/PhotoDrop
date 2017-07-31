current_team=`grep DEVELOPMENT_TEAM PhotoDrop.xcodeproj/project.pbxproj | head -n 1`
current_team=`echo $current_team | sed 's/.*= *\(.*\)\;/\1/'`

current_bundle=`grep PRODUCT_BUNDLE_IDENTIFIER PhotoDrop.xcodeproj/project.pbxproj | head -n 1`
current_bundle=`echo $current_bundle | sed 's/.*= *\(.*\)\;/\1/'`

if [ "$1" == "init" ]
then
  cat > switchUserSettings.sh << END
team=$current_team
bundle=$current_bundle
END
else
  . switchuserSettings.sh
  sed -i '' "s/${current_bundle}/${bundle}/g" PhotoDrop.xcodeproj/project.pbxproj
  sed -i '' "s/${current_team}/${team}/g" PhotoDrop.xcodeproj/project.pbxproj
fi

