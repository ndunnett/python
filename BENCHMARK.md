# Benchmark
This file is automatically generated by a [GitHub Action](/../../actions/workflows/benchmark.yml). The latest image for [ndunnett/python](https://hub.docker.com/r/ndunnett/python) and the official [Python](https://hub.docker.com/_/python) image are pulled and used to run [PyPerformance](https://pyperformance.readthedocs.io/), with the results then compared and formatted into this document.

## Official Python
- Performance version: 1.11.0
- Report on Linux-6.5.0-1022-azure-x86_64-with-glibc2.36
- Number of logical CPUs: 4
- Start date: 2024-07-06 14:52:02.479659
- End date: 2024-07-06 16:58:19.839076

## ndunnett/python
- Performance version: 1.11.0
- Report on Linux-6.5.0-1022-azure-x86_64-with-glibc2.39
- Number of logical CPUs: 4
- Start date: 2024-07-06 14:51:22.794403
- End date: 2024-07-06 16:45:25.102207

## Comparison
| Benchmark                        | Official Python | ndunnett/python | Change       | Significance           |
|----------------------------------|---------------|---------------|--------------|------------------------|
| 2to3                             | 330 ms        | 305 ms        | 1.08x faster | Significant (t-37.61)  |
| async_generators                 | 605 ms        | 523 ms        | 1.16x faster | Significant (t-90.00)  |
| async_tree_cpu_io_mixed          | 918 ms        | 734 ms        | 1.25x faster | Significant (t-65.91)  |
| async_tree_cpu_io_mixed_tg       | 851 ms        | 703 ms        | 1.21x faster | Significant (t-65.64)  |
| async_tree_eager                 | 137 ms        | 128 ms        | 1.07x faster | Significant (t-36.18)  |
| async_tree_eager_cpu_io_mixed    | 522 ms        | 429 ms        | 1.22x faster | Significant (t-91.87)  |
| async_tree_eager_cpu_io_mixed_tg | 455 ms        | 372 ms        | 1.23x faster | Significant (t-92.19)  |
| async_tree_eager_io              | 1.56 sec      | 1.36 sec      | 1.15x faster | Significant (t-39.13)  |
| async_tree_eager_io_tg           | 1.48 sec      | 1.26 sec      | 1.17x faster | Significant (t-29.35)  |
| async_tree_eager_memoization     | 323 ms        | 275 ms        | 1.18x faster | Significant (t-44.85)  |
| async_tree_eager_memoization_tg  | 243 ms        | 218 ms        | 1.12x faster | Significant (t-34.19)  |
| async_tree_eager_tg              | 95.7 ms       | 89.7 ms       | 1.07x faster | Significant (t-24.93)  |
| async_tree_io                    | 1.33 sec      | 1.12 sec      | 1.19x faster | Significant (t-58.48)  |
| async_tree_io_tg                 | 1.30 sec      | 1.13 sec      | 1.15x faster | Significant (t-63.35)  |
| async_tree_memoization           | 717 ms        | 598 ms        | 1.20x faster | Significant (t-28.42)  |
| async_tree_memoization_tg        | 631 ms        | 550 ms        | 1.15x faster | Significant (t-24.57)  |
| async_tree_none                  | 593 ms        | 484 ms        | 1.23x faster | Significant (t-78.28)  |
| async_tree_none_tg               | 499 ms        | 439 ms        | 1.14x faster | Significant (t-65.16)  |
| asyncio_tcp                      | 471 ms        | 585 ms        | 1.24x slower | Significant (t--97.02) |
| asyncio_tcp_ssl                  | 1.55 sec      | 1.76 sec      | 1.14x slower | Significant (t--72.86) |
| asyncio_websockets               | 685 ms        | 679 ms        | 1.01x faster | Not significant        |
| bench_mp_pool                    | 11.7 ms       | 12.0 ms       | 1.03x slower | Not significant        |
| bench_thread_pool                | 1.68 ms       | 1.60 ms       | 1.05x faster | Significant (t-8.23)   |
| chameleon                        | 8.22 ms       | 7.72 ms       | 1.06x faster | Significant (t-25.31)  |
| chaos                            | 84.0 ms       | 75.6 ms       | 1.11x faster | Significant (t-43.63)  |
| comprehensions                   | 21.1 us       | 19.0 us       | 1.11x faster | Significant (t-38.00)  |
| coroutines                       | 32.0 ms       | 30.5 ms       | 1.05x faster | Significant (t-19.15)  |
| coverage                         | 64.2 ms       | 57.3 ms       | 1.12x faster | Significant (t-28.64)  |
| create_gc_cycles                 | 1.14 ms       | 1.06 ms       | 1.08x faster | Significant (t-51.49)  |
| crypto_pyaes                     | 94.4 ms       | 81.2 ms       | 1.16x faster | Significant (t-86.84)  |
| dask                             | 658 ms        | 524 ms        | 1.25x faster | Significant (t-90.01)  |
| deepcopy                         | 430 us        | 399 us        | 1.08x faster | Significant (t-40.92)  |
| deepcopy_memo                    | 41.7 us       | 40.5 us       | 1.03x faster | Significant (t-4.40)   |
| deepcopy_reduce                  | 4.07 us       | 3.70 us       | 1.10x faster | Significant (t-36.79)  |
| deltablue                        | 3.90 ms       | 3.74 ms       | 1.04x faster | Significant (t-16.69)  |
| django_template                  | 58.5 ms       | 41.8 ms       | 1.40x faster | Significant (t-154.48) |
| docutils                         | 3.20 sec      | 2.79 sec      | 1.14x faster | Significant (t-66.32)  |
| dulwich_log                      | 92.7 ms       | 87.2 ms       | 1.06x faster | Significant (t-33.84)  |
| fannkuch                         | 439 ms        | 383 ms        | 1.15x faster | Significant (t-100.13) |
| float                            | 108 ms        | 91.4 ms       | 1.18x faster | Significant (t-46.96)  |
| gc_traversal                     | 3.10 ms       | 3.29 ms       | 1.06x slower | Significant (t--16.44) |
| generators                       | 46.0 ms       | 43.6 ms       | 1.06x faster | Significant (t-13.93)  |
| genshi_text                      | 29.1 ms       | 27.8 ms       | 1.05x faster | Significant (t-16.18)  |
| genshi_xml                       | 63.6 ms       | 61.0 ms       | 1.04x faster | Significant (t-12.96)  |
| go                               | 160 ms        | 154 ms        | 1.04x faster | Significant (t-20.60)  |
| hexiom                           | 7.40 ms       | 6.79 ms       | 1.09x faster | Significant (t-21.76)  |
| html5lib                         | 80.2 ms       | 75.0 ms       | 1.07x faster | Significant (t-11.81)  |
| json_dumps                       | 12.4 ms       | 10.4 ms       | 1.19x faster | Significant (t-138.20) |
| json_loads                       | 35.3 us       | 26.0 us       | 1.36x faster | Significant (t-136.39) |
| logging_format                   | 9.06 us       | 7.92 us       | 1.14x faster | Significant (t-52.75)  |
| logging_silent                   | 112 ns        | 113 ns        | 1.01x slower | Not significant        |
| logging_simple                   | 8.15 us       | 7.26 us       | 1.12x faster | Significant (t-61.27)  |
| mako                             | 12.2 ms       | 11.6 ms       | 1.05x faster | Significant (t-22.65)  |
| mdp                              | 3.31 sec      | 2.54 sec      | 1.30x faster | Significant (t-75.45)  |
| meteor_contest                   | 125 ms        | 107 ms        | 1.17x faster | Significant (t-181.83) |
| nbody                            | 131 ms        | 125 ms        | 1.05x faster | Significant (t-21.25)  |
| nqueens                          | 109 ms        | 94.9 ms       | 1.15x faster | Significant (t-67.77)  |
| pathlib                          | 36.7 ms       | 33.9 ms       | 1.08x faster | Significant (t-52.78)  |
| pickle                           | 16.5 us       | 10.1 us       | 1.63x faster | Significant (t-216.73) |
| pickle_dict                      | 38.9 us       | 28.0 us       | 1.39x faster | Significant (t-196.06) |
| pickle_list                      | 5.90 us       | 4.22 us       | 1.40x faster | Significant (t-115.35) |
| pickle_pure_python               | 387 us        | 336 us        | 1.15x faster | Significant (t-51.70)  |
| pidigits                         | 210 ms        | 179 ms        | 1.17x faster | Significant (t-185.38) |
| pprint_pformat                   | 1.92 sec      | 1.74 sec      | 1.11x faster | Significant (t-45.12)  |
| pprint_safe_repr                 | 948 ms        | 845 ms        | 1.12x faster | Significant (t-49.11)  |
| pyflate                          | 516 ms        | 467 ms        | 1.10x faster | Significant (t-43.79)  |
| python_startup                   | 11.7 ms       | 10.9 ms       | 1.07x faster | Significant (t-107.66) |
| python_startup_no_site           | 8.60 ms       | 7.86 ms       | 1.09x faster | Significant (t-103.80) |
| raytrace                         | 399 ms        | 364 ms        | 1.10x faster | Significant (t-59.38)  |
| regex_compile                    | 167 ms        | 155 ms        | 1.08x faster | Significant (t-33.47)  |
| regex_dna                        | 196 ms        | 187 ms        | 1.05x faster | Significant (t-17.01)  |
| regex_effbot                     | 3.68 ms       | 3.72 ms       | 1.01x slower | Not significant        |
| regex_v8                         | 25.3 ms       | 24.0 ms       | 1.06x faster | Significant (t-24.64)  |
| richards                         | 49.9 ms       | 49.8 ms       | 1.00x faster | Not significant        |
| richards_super                   | 56.9 ms       | 58.5 ms       | 1.03x slower | Significant (t--3.86)  |
| scimark_fft                      | 388 ms        | 345 ms        | 1.13x faster | Significant (t-59.56)  |
| scimark_lu                       | 143 ms        | 122 ms        | 1.17x faster | Significant (t-41.62)  |
| scimark_monte_carlo              | 85.5 ms       | 76.0 ms       | 1.13x faster | Significant (t-30.31)  |
| scimark_sor                      | 146 ms        | 140 ms        | 1.04x faster | Significant (t-8.68)   |
| scimark_sparse_mat_mult          | 5.69 ms       | 5.05 ms       | 1.13x faster | Significant (t-27.00)  |
| spectral_norm                    | 132 ms        | 114 ms        | 1.16x faster | Significant (t-30.29)  |
| sqlalchemy_declarative           | 189 ms        | 144 ms        | 1.31x faster | Significant (t-74.80)  |
| sqlalchemy_imperative            | 28.6 ms       | 22.2 ms       | 1.29x faster | Significant (t-45.91)  |
| sqlglot_normalize                | 141 ms        | 133 ms        | 1.06x faster | Significant (t-29.59)  |
| sqlglot_optimize                 | 69.6 ms       | 64.6 ms       | 1.08x faster | Significant (t-37.98)  |
| sqlglot_parse                    | 1.60 ms       | 1.49 ms       | 1.08x faster | Significant (t-25.74)  |
| sqlglot_transpile                | 1.96 ms       | 1.83 ms       | 1.07x faster | Significant (t-21.69)  |
| sqlite_synth                     | 3.31 us       | 2.62 us       | 1.26x faster | Significant (t-160.43) |
| sympy_expand                     | 573 ms        | 537 ms        | 1.07x faster | Significant (t-15.62)  |
| sympy_integrate                  | 23.6 ms       | 23.3 ms       | 1.02x faster | Not significant        |
| sympy_str                        | 338 ms        | 325 ms        | 1.04x faster | Significant (t-11.56)  |
| sympy_sum                        | 180 ms        | 175 ms        | 1.03x faster | Significant (t-7.21)   |
| telco                            | 9.82 ms       | 7.37 ms       | 1.33x faster | Significant (t-170.59) |
| tomli_loads                      | 2.70 sec      | 2.38 sec      | 1.14x faster | Significant (t-28.92)  |
| tornado_http                     | 156 ms        | 149 ms        | 1.05x faster | Significant (t-16.07)  |
| typing_runtime_protocols         | 234 us        | 192 us        | 1.22x faster | Significant (t-41.46)  |
| unpack_sequence                  | 48.5 ns       | 41.1 ns       | 1.18x faster | Significant (t-54.20)  |
| unpickle                         | 18.1 us       | 13.6 us       | 1.33x faster | Significant (t-87.29)  |
| unpickle_list                    | 6.57 us       | 5.03 us       | 1.31x faster | Significant (t-165.37) |
| unpickle_pure_python             | 269 us        | 241 us        | 1.12x faster | Significant (t-43.01)  |
| xml_etree_generate               | 109 ms        | 97.7 ms       | 1.12x faster | Significant (t-53.88)  |
| xml_etree_iterparse              | 135 ms        | 115 ms        | 1.17x faster | Significant (t-52.23)  |
| xml_etree_parse                  | 200 ms        | 157 ms        | 1.28x faster | Significant (t-110.79) |
| xml_etree_process                | 73.4 ms       | 67.3 ms       | 1.09x faster | Significant (t-50.01)  |
