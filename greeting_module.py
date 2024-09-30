# 인사말 관련 모듈 생성
# 패키지가 없는 모듈

__version__= 1.0

def print_greeting(name):
    print(f"{name}님 안녕하세요")

def print_welcome(name):
    print(f"{name}님 안녕하세요")

def get_greeting(name):
    return f"{name}님 안녕하세요"

class Hello:

    def __init__(self, name):
        self.name = name
        
    def kor_greet(self):
        return f"{self.name}님 안녕하세요"

    def eng_greet(self):
        return f"{self.name} Hello"

print(__name__)
if __name__ == "__main__": # main module일 때만 실행
    g = get_greeting("홍길동")
    print(g)
    print_welcome("유유유")  

