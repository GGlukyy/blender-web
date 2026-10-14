// M1 toolchain test: proves Emscripten + pthreads work.
#include <atomic>
#include <cstdio>
#include <thread>
#include <vector>

int main() {
  std::atomic<int> counter{0};
  std::vector<std::thread> workers;
  for (int i = 0; i < 4; i++) {
    workers.emplace_back([&counter] { counter.fetch_add(1); });
  }
  for (auto &t : workers) {
    t.join();
  }
  std::printf("HELLO FROM WASM, threads=%s\n", counter.load() == 4 ? "OK" : "FAIL");
  return counter.load() == 4 ? 0 : 1;
}
