# CPU_APB(Multicycle) 통합 시스템 설계

## 1. Block Diagram
![CPU_APB_Block_Diagram](https://github.com/user-attachments/assets/05103c22-dc16-4e77-9eaa-66e0e1dd9e26)

---

## 2. System Composition

### 2.1 Core & Bus 아키텍처
* **CPU Core:** RV32I 기반 Multicycle 프로세서
* **System Bus:** AMBA 3 APB (Advanced Peripheral Bus) 규격 준수
* **Bus Interconnect:** Address Decoder 및 PRDATA Multiplexer 내장

### 2.2 Memory Mapped I/O 주소 할당 (Slave 명세)
하드웨어 제어를 위해 전체 주소 공간을 아래와 같이 분할하여 배정

| Slave 명칭 | 주소 범위 (Address Range) | 주요 기능 |
| :--- | :--- | :--- |
| **BRAM_Slave** | `0x0000_0000 ~ 0x0000_3FFF` | 명령어 및 데이터 저장용 내부 메모리 (16KB) |
| **GPIO_Slave** | `0x4000_0000 ~ 0x4000_000F` | 스위치(Input) 및 LED(Output) 제어 레지스터 |
| **UART_Slave** | `0x4000_0010 ~ 0x4000_001F` | PC 터미널 통신용 직렬 인터페이스 (Tx/Rx FIFO 포함) |
| **FND_Slave** | `0x4000_0020 ~ 0x4000_002F` | 7-Segment 디스플레이 출력 제어 레지스터 |

---

## 3. Multicycle CPU Core 아키텍처

### 3.1 파이프라인 개념 접목을 위한 레지스터 구성
기존 Single-cycle 아키텍처와 달리, 각 주요 데이터패스(Datapath) 단계마다 중간 결과 값을 보존하는 내부 레지스터를 설치하여 데이터 손상을 방지 및 동작 주파수 제어

* **추가된 내부 파이프라인 레지스터:**
  * **IR (Instruction Register) / Data Reg:** Fetch 단계의 명령어 및 메모리 리드 데이터 보존
  * **Source Reg 1 & 2:** 레지스터 파일에서 읽어온 $RS1, RS2$ 값을 ALU 입력 전단에 래치(Latch)
  * **ALU Out Register:** 산술 논리 연산 장치(ALU)의 연산 결과를 한 클럭 저장
  * **Read Data Register:** 데이터 메모리(BRAM)에서 읽어온 값을 WB 단계 전단에 저장

### 3.2 CPU 제어 FSM (Finite State Machine)
프로세서는 상태 천이에 따라 순차 제어되며, **MEM 상태에서 외부 APB 버스 접근 시 동기화(Stall) 로직**이 동작

* **FSM States:** `FETCH` → `DECODE` → `EXECUTE` → `MEM (Stall 가능)` → `WRITE_BACK`
* **하드웨어 제어 최적화 (`pc_en`):** * 분기문 연산이 완료되거나 차기 명령어 로드가 확정되는 특정 상태(`FETCH`, `EXECUTE` 중 Branch 만족 시)에서만 `pc_en` 신호를 활성화하여 PC(Program Counter) 값을 안전하게 업데이트

---

## 4. AMBA APB Bus 규격 및 구현 (MASTER)

### 4.1 Bus Master 제어 상태도 (FSM)
APB Master는 CPU Core의 요청(`w_req`, `r_req`)을 받아 표준 3상태 FSM을 수행

1. **IDLE:** 기본 대기 상태. 전송 요청이 없을 경우 이 상태를 유지합니다.
2. **SETUP:** 전송 요청 발생 시 진입. 주소(`PADDR`)와 데이터(`PWDATA`)를 구동하고 `PSELx` 신호를 활성화합니다. (1 클럭 지속)
3. **ACCESS:** `PENABLE` 신호를 활성화하여 실제 데이터 전송을 개시합니다. Slave가 준비 완료 신호(`PREADY = 1`)를 줄 때까지 이 상태를 유지(Wait State)하며, 완료되면 다시 `IDLE`로 복귀

### 4.2 프로토콜 인터페이스 신호 명세

| 신호명 (Signal) | 방향 (Master 기준) | 설명 |
| :--- | :--- | :--- |
| **PCLK** | Input | 시스템 기본 동기화 클럭 |
| **PRESETn** | Input | 액티브 로우(Active-Low) 비동기 시스템 리셋 |
| **PADDR [31:0]** | Output | CPU가 접근하고자 하는 주변장치의 32비트 절대 주소 |
| **PSELx** | Output | Address Decoder를 통해 선택된 특정 Slave 활성화 신호 |
| **PENABLE** | Output | APB Access 단계를 나타내는 활성화 신호 |
| **PWRITE** | Output | High(1)일 때 Write 동작, Low(0)일 때 Read 동작 명시 |
| **PWDATA [31:0]** | Output | Slave 레지스터에 쓰고자 하는 32비트 데이터 |
| **PREADY** | Input | Slave가 통신할 준비가 되었음을 알리는 신호 (0일 경우 버스 Stall 발생) |
| **PRDATA [31:0]** | Input | 선택된 Slave로부터 읽어온 32비트 데이터 (인터커넥터 Mux를 거침) |

---

## 5. CPU-APB 동기화 및 인터커넥터 구현 규칙

### 5.1 CPU MEM 단계에서의 Stall 제어 메커니즘
* Memory Mapped I/O 영역 접근 시 CPU FSM은 `MEM` 상태에서 대기
* APB Bus Master가 `ACCESS` 상태를 끝내고 `PREADY` 신호가 High(1)로 들어오는 시점에 CPU FSM에 완료 플래그를 전달하며, 이 플래그를 확인한 후에야 CPU는 다음 상태인 `WRITE_BACK` 또는 `FETCH`로 천이하여 데이터 유실을 방지

### 5.2 Address Decoding & PRDATA Muxing Logic
* **Address Decoder:** Master가 출력하는 `PADDR`의 상위 비트를 판별하여 단 하나의 `PSELx`(`PSEL_BRAM`, `PSEL_GPIO`, `PSEL_UART`, `PSEL_FND`)만 High로 구동
* **PRDATA Mux:** 현재 활성화된 `PSELx` 기반 선택 플래그를 멀티플렉서 제어 신호로 사용하여, 해당 Slave의 출력 데이터만을 Master의 `PRDATA` 입력으로 연결

---
