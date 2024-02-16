defmodule SpringsMem do
  def parse([]) do [] end
  def parse(string) do
    [first, second] = String.split(string)
    status = String.to_charlist(first)
    status = Enum.map(status, fn x -> if x === 63, do: :unk, else: x end)
    status = Enum.map(status, fn x -> if x === 46, do: :op, else: x end)
    status = Enum.map(status, fn x -> if x === 35, do: :dam, else: x end)
    pattern = ","
    numberlist = String.split(second, pattern)
    damaged = parse_num_to_str(numberlist)
    {status, damaged}
  end

  def parse_num_to_str([]) do [] end
  def parse_num_to_str([head|tail]) do
    [String.to_integer(head)|parse_num_to_str(tail)]
  end

  def multi_string(status, damaged_list, n) do
    # dup_status = String.duplicate(status <> "?", n)
    # final_status = String.slice(dup_status, 0, String.length(dup_status) - 1)
    spring_pattern = String.duplicate(status, n) <> " " <> String.duplicate(damaged_list <> ",", n)
    String.slice(spring_pattern, 0, String.length(spring_pattern) - 1)
  end

  # Handle the cases when the number of damaged springs is already 0.
  # Then, the spring after the last damaged spring must either be operational, unknown or empty
  def damaged([], 0) do
    {:ok, []}
  end
  def damaged([:dam | _], 0) do
    :nil
  end
  def damaged([ _ | rest], 0) do
    {:ok, rest}
  end

  # Handle the case when we have empty status, but the number of damaged springs is not 0.
  def damaged([], _) do
    :nil
  end
  # Handle the case when we have operational spring, but the number of damaged springs is not 0.
  def damaged([:op | _], _) do
    :nil
  end
  # Handle other cases, if it is unknown, it must be damaged.
  def damaged([_ | rest], n) do
    damaged(rest, n-1)
  end

  def solve({[], []}, mem) do
    {1, mem}
  end
  def solve({[], _}, mem) do
    {0, mem}
  end
  def solve({[:op | rest], []}, mem) do
    solve({rest, []}, mem)
  end
  def solve({[:dam | _], []}, mem) do
    {0, mem}
  end
  def solve({[:unk | rest], []}, mem) do
    solve({rest, []}, mem)
  end
  def solve({[ :op | status_rest], damaged}, mem) do
    solve({status_rest, damaged}, mem)
  end

  def solve({[ :dam | status_rest], [n | damaged_rest]}, mem) do
    case damaged(status_rest, n-1) do
      {:ok, status_rest} -> solve({status_rest, damaged_rest}, mem)
      :nil -> {0, mem}
    end
  end


  # ???...### 1,1,3
  # ###...###
  def solve({[ :unk | status_rest], damaged}, mem) do
    {dam_pos, mem} = solve_unknown({[ :dam | status_rest], damaged}, mem)
    {op_pos, mem} = solve_unknown({[ :op | status_rest], damaged}, mem)
    {dam_pos+op_pos, mem}
  end

  def solve_unknown({status, damaged}, mem) do
    case mem[{status, damaged}] do
      :nil ->
        {num_pos, mem} = solve({status, damaged}, mem)
        {num_pos, Map.put(mem, {status, damaged}, num_pos)}
      num_pos ->
        {num_pos, mem}
    end
  end

  def solve_pattern(pattern) do
    solve(parse(pattern), Map.new())
  end

  def bench(n) do
    Enum.map(1..n, fn i ->
      pattern = multi_string("????.######..#####.", "1,6,5", i)
      {time, _} = :timer.tc(SpringsMem, :solve_pattern, [pattern])
      IO.inspect(time)
    end)
    :ok
  end
end
