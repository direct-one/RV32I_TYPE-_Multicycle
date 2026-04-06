# CPU_APB(Multicycle)

# CPU_APB

## Composition

- CPU
    - RV32I -Muticycle
- APB
- MASTER
- SLAVE
    - BRAM_Slave
    - GPIO_Slave
    - UART_Slave
    - FND_Slave
- Ccode(Sw/Led(in/out)) ( Software)

---

## Mulcticycle

- 기존 Single cylcle과 다르게, 각 출력값에 Register를 설치, pipeline의 구조를 비슷하게 표현
    
    → Muticycle에서는 명령어가 순차적으로 나오지 않기 때문에, 값이 덮여져 데이터의 손상이 나타나는 현상이 발생할 수 있음 
    
- Register의 추가로 인해 데이터 손실을 방지하여, pipeline 구조를 재현
- **State**: FETCH, DECODE, EXECUTE, WB, MEM

### Single cycle의 차이점

- **Register 추가**
    - RS1-ALU(자동 연산 장치)
    - RS2(mux)-ALU(자동 연산 장치)
    - ALU-Data-memory
    - Data-memory - mux5x1(1)
    
- **pc_en 추가**
    - pc_en을 통해 state를 통해 신호가 나오는 경우에만, pc 출력 
    

---

# AMBA APB

## Memory Mapped IO

- IO를 Memory처럼 사용하겠다는 전략
    - BUS를 사용
    - ROM, RAM, GPO, GPI, GPIO,FND, UART로 나뉘어 구성

## APB CPU Implementation(Signal & Connect)(MASTER)

### State

- IDLE → Set up → Access → IDLE
- Transfer를 정하는 신호는: PSEL
- Access에서 동작의 유무를 정하는 신호: PENABLE
- commit Wirte: w_req
- commit READ r_req

### Signal

- PCLK: clk
- PPRESET: rst
- PADDR: address
- PSELx: 선택 신호 **(각 연결마다 다르게 설정)**
- PENABLE: 활성화 신호
- PWRITE: wirte를 할 수 있게 Access해주는 신호
- PWDATA:  WRITE할 값
- PREADY: Transfer를 연장하기 위한 신호 (1인 경우,  state의 동작이 실시됨)
- PRDATA:  read data**(각 연결마다 다르게 설정)**

### Slave

- BRAM_Slave
- GPIO_Slave
- UART_Slave
- FND_Slave
