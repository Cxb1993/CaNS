module mod_load
  use mpi
  use mod_common_mpi, only: ierr 
  use decomp_2d
  use decomp_2d_io
  implicit none
  private
  public load
  contains
  subroutine load(io,filename,n,u,v,w,p,time,istep)
    implicit none
    character(len=1)  , intent(in) :: io
    character(len=*), intent(in) :: filename
    integer, intent(in), dimension(3) :: n
    real(8), intent(inout), dimension(n(1),n(2),n(3)) :: u,v,w,p
    real(8), intent(inout) :: time,istep
    real(8), dimension(2) :: fldinfo
    integer :: fh
    integer(kind=MPI_OFFSET_KIND) :: filesize,disp
    select case(io)
      case('r')
        call MPI_FILE_OPEN(MPI_COMM_WORLD, filename                 , &
             MPI_MODE_RDONLY, MPI_INFO_NULL,fh, ierr)
        disp = 0_MPI_OFFSET_KIND
        call decomp_2d_read_var(fh,disp,3,u)
        call decomp_2d_read_var(fh,disp,3,v)
        call decomp_2d_read_var(fh,disp,3,w)
        call decomp_2d_read_var(fh,disp,3,p)
        call decomp_2d_read_scalar(fh,disp,2,fldinfo)
        call MPI_FILE_CLOSE(fh,ierr)
        time  = fldinfo(1)
        istep = fldinfo(2)
      case('w')
        fldinfo = (/time,istep/)
        call MPI_FILE_OPEN(MPI_COMM_WORLD, filename                 , &
             MPI_MODE_CREATE+MPI_MODE_WRONLY, MPI_INFO_NULL,fh, ierr)
        filesize = 0_MPI_OFFSET_KIND
        call MPI_FILE_SET_SIZE(fh,filesize,ierr)  ! guarantee overwriting
        disp = 0_MPI_OFFSET_KIND
        call decomp_2d_write_var(fh,disp,3,u)
        call decomp_2d_write_var(fh,disp,3,v)
        call decomp_2d_write_var(fh,disp,3,w)
        call decomp_2d_write_var(fh,disp,3,p)
        call decomp_2d_write_scalar(fh,disp,2,fldinfo)
        call MPI_FILE_CLOSE(fh,ierr)
    end select
    return
  end subroutine load
end module mod_load
