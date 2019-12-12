Experiment _aERWARzHEeqwm8NtKul7GQ {
  Package "de.learnlib.studio.examples"
  Name "LearnMealy"
  Start _aEYDsRzHEeqwm8NtKul7GQ at 50,50 size 100,65 {
  	-StartEdge-> _tkZGsRzHEeqwm8NtKul7GQ  decorate "Text" at (0,0) decorate "" at (0,0) {
  		id _2YARYRzHEeqwm8NtKul7GQ
  	}
  }
  
  MealyMembershipOracle _ayDpERzHEeqwm8NtKul7GQ at 500,190 size 191,65 {
  }
  
  RandomWordEQOracle _pkaDERzHEeqwm8NtKul7GQ at 50,370 size 230,65 {
  	amount 20
  	minLength 5
  	maxLength 10
  	-QueryEdge-> _ayDpERzHEeqwm8NtKul7GQ  decorate "Text" at (0,0) decorate "" at (0,0) decorate "" at (0,0) {
  		id _wchxcRzHEeqwm8NtKul7GQ
  	}
  	
  	-WordEdge-> _tkZGsRzHEeqwm8NtKul7GQ via (9,421) (9,223) decorate "Text" at (0,0) decorate "" at (0,0) {
  		id _xFcyoRzHEeqwm8NtKul7GQ
  	}
  	
  	-ModelEdge-> _3DAWMRzHEeqwm8NtKul7GQ  decorate "Text" at (0,0) decorate "" at (0,0) {
  		id _3lIL0RzHEeqwm8NtKul7GQ
  	}
  }
  
  TTTAlgorithm _tkZGsRzHEeqwm8NtKul7GQ at 50,190 size 120,65 {
  	acexAnalyzer BinarySearchBackward
  	-QueryEdge-> _ayDpERzHEeqwm8NtKul7GQ  decorate "Text" at (0,0) decorate "" at (0,0) decorate "" at (0,0) {
  		id _wIO8cRzHEeqwm8NtKul7GQ
  	}
  	
  	-ModelEdge-> _pkaDERzHEeqwm8NtKul7GQ  decorate "Text" at (0,0) decorate "" at (0,0) {
  		id _0feCcRzHEeqwm8NtKul7GQ
  	}
  }
  
  MealySul _umy-4RzHEeqwm8NtKul7GQ at 520,390 size 161,65 {
  	libraryComponentUID "_ClQHoOj5Eei7hv4jTWl9Hg"
  	-SulEdge-> _ayDpERzHEeqwm8NtKul7GQ  decorate "Text" at (0,0) decorate "" at (0,0) decorate "" at (0,0) {
  		id _vtL_MRzHEeqwm8NtKul7GQ
  	}
  }
  
  ShowModel _3DAWMRzHEeqwm8NtKul7GQ at 67,480 size 195,65 {
  }
}
