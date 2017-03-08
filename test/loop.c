
int main(){
	int i;
	int s = 0;

	for(i = 0; i < 10; i++){
		s += i;
	}

	while(i > 0){
		s += i;
		i--;
	}

	return s;
}