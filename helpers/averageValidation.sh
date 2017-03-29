#!/bin/bash

dropboxAnalysisDir=$1





for d in `ls "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/`; do
	if [ "$d" -lt "092916" ] && [ "$d" -gt "081816" ]; then
		badDate=$d
	else
		numberSubjects=`ls "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d | grep Cache-LMS | grep -c mat`
		for (( s=1; s<=numberSubjects; s++ )); do
			for stimulation in 1 2; do
				subject=`ls "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d | grep Cache-LMS | grep mat | awk "/Cache/{i++}i==$s" | awk '{split($0,a,"_"); print a[3]}'`

				if [ $stimulation -eq 1 ]; then
					cacheDirectory=Cache-LMSDirectedSuperMaxLMS_MELA_${subject}_$d
					resultsDirectory=PIPRMaxPulse_PulseLMS
				fi 
				if [ $stimulation -eq 2 ]; then
					cacheDirectory=Cache-MelanopsinDirectedSuperMaxMel_MELA_${subject}_$d
					resultsDirectory=PIPRMaxPulse_PulseMel
				fi 
			
			

				onePreFile=`ls "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/ | awk "/""/{i++}i==1"`
				SOnePre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$onePreFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 3p`
				LMSOnePre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$onePreFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`
				LMinusMOnePre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$onePreFile/*.txt | grep "LConeTabulatedAbsorbance - MConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 1p`
				MelOnePre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$onePreFile/*.txt | grep "Melanopsin" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`
			
				twoPreFile=`ls "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/ | awk "/""/{i++}i==2"`
				STwoPre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$twoPreFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 3p`
				LMSTwoPre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$twoPreFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`
				LMinusMTwoPre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$twoPreFile/*.txt | grep "LConeTabulatedAbsorbance - MConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 1p`
				MelTwoPre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$twoPreFile/*.txt | grep "Melanopsin" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`
						
				threePreFile=`ls "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/ | awk "/""/{i++}i==3"`
				SThreePre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$threePreFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 3p`
				LMSThreePre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$threePreFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`
				LMinusMThreePre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$threePreFile/*.txt | grep "LConeTabulatedAbsorbance - MConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 1p`
				MelThreePre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$threePreFile/*.txt | grep "Melanopsin" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`						
				
				fourPreFile=`ls "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/ | awk "/""/{i++}i==4"`
				SFourPre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$fourPreFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 3p`
				LMSFourPre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$fourPreFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`
				LMinusMFourPre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$fourPreFile/*.txt | grep "LConeTabulatedAbsorbance - MConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 1p`
				MelFourPre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$fourPreFile/*.txt | grep "Melanopsin" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`
			
				fivePreFile=`ls "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/ | awk "/""/{i++}i==5"`
				SFivePre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$fivePreFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 3p`
				LMSFivePre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$fivePreFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`
				LMinusMFivePre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$fivePreFile/*.txt | grep "LConeTabulatedAbsorbance - MConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 1p`
				MelFivePre=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$fivePreFile/*.txt | grep "Melanopsin" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`
			
				onePostFile=`ls "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/ | awk "/""/{i++}i==6"`
				SOnePost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$onePostFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 3p`
				LMSOnePost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$onePostFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`
				LMinusMOnePost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$onePostFile/*.txt | grep "LConeTabulatedAbsorbance - MConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 1p`
				MelOnePost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$onePostFile/*.txt | grep "Melanopsin" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`
			
				twoPostFile=`ls "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/ | awk "/""/{i++}i==7"`
				STwoPost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$twoPostFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 3p`
				LMSTwoPost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$twoPostFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`
				LMinusMTwoPost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$twoPostFile/*.txt | grep "LConeTabulatedAbsorbance - MConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 1p`
				MelTwoPost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$twoPostFile/*.txt | grep "Melanopsin" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`
			
				threePostFile=`ls "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/ | awk "/""/{i++}i==8"`
				SThreePost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$threePostFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 3p`
				LMSThreePost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$threePostFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`
				LMinusMThreePost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$threePostFile/*.txt | grep "LConeTabulatedAbsorbance - MConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 1p`
				MelThreePost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$threePostFile/*.txt | grep "Melanopsin" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`
			
			
				fourPostFile=`ls "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/ | awk "/""/{i++}i==9"`
				SFourPost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$fourPostFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 3p`
				LMSFourPost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$fourPostFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`
				LMinusMFourPost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$fourPostFile/*.txt | grep "LConeTabulatedAbsorbance - MConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 1p`
				MelFourPost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$fourPostFile/*.txt | grep "Melanopsin" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`
			
				fivePostFile=`ls "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/ | awk "/""/{i++}i==10"`
				SFivePost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$fivePostFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 3p`
				LMSFivePost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$fivePostFile/*.txt | grep "SConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`
				LMinusMFivePost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$fivePostFile/*.txt | grep "LConeTabulatedAbsorbance - MConeTabulatedAbsorbance" | awk '{split($0,a,"="); print a[2]}' | sed -n 1p`
				MelFivePost=`more "$dropboxAnalysisDir"/MELA_materials/PIPRMaxPulse/$d/${cacheDirectory}/$fivePostFile/*.txt | grep "Melanopsin" | awk '{split($0,a,"="); print a[2]}' | sed -n 2p`
			
			
				preSTotal=$(bc <<< "scale=6;$SOnePre+$STwoPre+$SThreePre+$SFourPre+$SFivePre")
				preS=$(bc <<< "scale=6;$preSTotal/5")
			
				postSTotal=$(bc <<< "scale=6;$SOnePost+$STwoPost+$SThreePost+$SFourPost+$SFivePost")
				postS=$(bc <<< "scale=6;$postSTotal/5")
			
				preLMSTotal=$(bc <<< "scale=6;$LMSOnePre+$LMSTwoPre+$LMSThreePre+$LMSFourPre+$LMSFivePre")
				preLMS=$(bc <<< "scale=6;$preLMSTotal/5")
			
				postLMSTotal=$(bc <<< "scale=6;$LMSOnePost+$LMSTwoPost+$LMSThreePost+$LMSFourPost+$LMSFivePost")
				postLMS=$(bc <<< "scale=6;$postLMSTotal/5")
			
				preLMinusMTotal=$(bc <<< "scale=6;$LMinusMOnePre+$LMinusMTwoPre+$LMinusMThreePre+$LMinusMFourPre+$LMinusMFivePre")
				preLMinusM=$(bc <<< "scale=6;$preLMinusMTotal/5")
			
				postLMinusMTotal=$(bc <<< "scale=6;$LMinusMOnePost+$LMinusMTwoPost+$LMinusMThreePost+$LMinusMFourPost+$LMinusMFivePost")
				postLMinusM=$(bc <<< "scale=6;$postLMinusMTotal/5")
			
				preMelTotal=$(bc <<< "scale=6;$MelOnePre+$MelTwoPre+$MelThreePre+$MelFourPre+$MelFivePre")
				preMel=$(bc <<< "scale=6;$preMelTotal/5")
			
				postMelTotal=$(bc <<< "scale=6;$MelOnePost+$MelTwoPost+$MelThreePost+$MelFourPost+$MelFivePost")
				postMel=$(bc <<< "scale=6;$postMelTotal/5")
			
			
				if [ $postMel != "" ]; then
					echo "subject,date,LMS,L-M,S,Mel" > "$dropboxAnalysisDir"/MELA_analysis/${resultsDirectory}/MELA_${subject}/${d}/preSessionSplatterValidationStats.txt
					echo "$subject,$d,$preLMS,$preLMinusM,$preS,$preMel" >> "$dropboxAnalysisDir"/MELA_analysis/${resultsDirectory}/MELA_${subject}/${d}/preSessionSplatterValidationStats.txt
				
					echo "subject,date,LMS,L-M,S,Mel" > "$dropboxAnalysisDir"/MELA_analysis/${resultsDirectory}/MELA_${subject}/${d}/postSessionSplatterValidationStats.txt
					echo "$subject,$d,$postLMS,$postLMinusM,$postS,$postMel" >> "$dropboxAnalysisDir"/MELA_analysis/${resultsDirectory}/MELA_${subject}/${d}/postSessionSplatterValidationStats.txt
				
					echo "$subject,$d,$preLMS,$preLMinusM,$preS,$preMel" >> ~/validationStats.txt
				fi
			
			done
				
			
		done
			
	fi
done