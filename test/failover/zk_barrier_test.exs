defmodule Failover.ZKHelper.Test do
  use ExUnit.Case
  require Logger
  import FailoverMocks

  alias Failover.ZKBarrier

  @tag :unit
  test "it notifies the monitor that it's safe to work on zk conn" do
    state = make_zk_barrier_state()

    assert GenServer.call(state[:monitor], :safe_to_work) == false
    
    ZKBarrier.handle_info({:connected, 'localhost', 2181}, state)

    assert GenServer.call(state[:monitor], :safe_to_work) == true
  end

  @tag :unit
  test "upon zk disconnection, notifies monitor it's unsafe to continue" do
    state = make_zk_barrier_state()

    assert GenServer.call(state[:monitor], :safe_to_work) == false
    
    ZKBarrier.handle_info({:connected, 'localhost', 2181}, state)

    assert GenServer.call(state[:monitor], :safe_to_work) == true

    ZKBarrier.handle_info({:disconnected, 'localhost', 2181}, state)
    
    assert GenServer.call(state[:monitor], :safe_to_work) == false
  end
  
  @tag :unit
  test "upon zk session expire, notifies monitor it's unsafe to continue" do
    state = make_zk_barrier_state()

    assert GenServer.call(state[:monitor], :safe_to_work) == false
    
    ZKBarrier.handle_info({:connected, 'localhost', 2181}, state)

    assert GenServer.call(state[:monitor], :safe_to_work) == true

    ZKBarrier.handle_info({:expired, 'localhost', 2181}, state)
    
    assert GenServer.call(state[:monitor], :safe_to_work) == false
  end
end
