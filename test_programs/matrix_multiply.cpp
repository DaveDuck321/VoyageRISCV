#include <array>
#include <cstdint>

template <std::size_t Height, std::size_t Width> struct Matrix {
  std::array<std::array<int, Width>, Height> data;

  std::uint8_t hash() {
    std::uint8_t result = 0;
    for (const auto &row : data) {
      for (const auto value : row) {
        result ^= value;
      }
    }
    return result;
  }
  auto &operator[](const std::size_t index) { return data[index]; }
  const auto &operator[](const std::size_t index) const { return data[index]; }
};

template <std::size_t Result_Height, std::size_t Result_Width,
          std::size_t Inner_Dim>
auto operator*(const Matrix<Result_Height, Inner_Dim> &lhs,
               const Matrix<Inner_Dim, Result_Width> &rhs) {

  Matrix<Result_Height, Result_Width> result;
  for (std::size_t result_y = 0; result_y < Result_Height; result_y++) {
    for (std::size_t result_x = 0; result_x < Result_Width; result_x++) {
      int inner_sum = 0;
      for (std::size_t inner = 0; inner < Inner_Dim; inner++) {
        inner_sum += lhs[result_y][inner] * rhs[inner][result_x];
      }
      result[result_y][result_x] = inner_sum;
    }
  }
  return result;
}

extern "C" int main() {
  volatile std::uint8_t &output_io = *(std::uint8_t *)0x2000;
  Matrix<2, 2> mat_a{.data{{{1, 2}, {3, 4}}}};
  Matrix<2, 2> mat_b{.data{{{4, 5}, {6, 7}}}};

  auto mat_c = mat_a * mat_b;
  output_io = 0xFF;
  output_io = mat_c.hash();    // Should be 12

  while (1) {
  }
}
