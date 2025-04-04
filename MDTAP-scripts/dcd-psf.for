      implicit none
      character*80             :: filename,psfname,psname,outfile
      double precision         :: d
      real                     :: t,dummyr
      real,allocatable         :: x(:,:),y(:,:),z(:,:)
      integer                  :: nset,natom,dummyi,i,j,k,l,m,nframes
      character*4              :: dummyc
      ! psf file variables
      character*14             :: junk(4)
      character*4              :: atom
      integer                  :: skipframe,numatm
      integer,allocatable      :: anum(:),resid(:),atlist(:),update(:)
      character*4,allocatable  :: segid(:),atname(:),resname(:)
      ! input required for MDTAP analysis
      integer                  :: startfrm,endfrm,skipfrm,totframe
      integer                  :: dcdstart,dcdend, totdcd
      ! For the atom list given as the input
      character*4              :: atsel, resel, residue
      integer                  :: numselat
      ! Output datfile
      character*80             :: datfile, location, pdbname,atlistdat, 
     *                            inputlocat
      ! read MDTAP analysis
      read(*,*) dcdstart,dcdend,startfrm,endfrm,skipfrm,atsel,resel,
     *residue,psfname,location,inputlocat

! Input PSF file and format
      write(psname,'(a,a,a)') trim(inputlocat),'/',trim(psfname)
      open(11,file=trim(psname),status='old',
     * form='formatted')
 
 4    format(i10,x,a4,2x,i6,6x,a4,5x,a4)
! Input atomic number dat file 
      write(atlistdat,'(a,a)') trim(location),"/atmlist.dat"
      open(1,file=trim(atlistdat),status='old')
! Output dat file format
 16   format(i10,3x,a4,3x,f8.3,3x,f8.3,3x,f8.3,3x,a4,3x,a4,3x,i4)
! Output PDB file and format
 5    format(a4,x,i6,x,a4,x,a4,x,i4,4x,f8.3,f8.3,f8.3,18x,4a)
 6    write(pdbname,'(a,a)') trim(location),'/step_1.pdb'
      open(12,file=trim(pdbname),status='new')

C Reading the formatted PSF file: Atom name, resid, segid is required to
C create the PDB file
      atom="ATOM"

      read(11,*) numatm
      allocate(anum(numatm))
      allocate(resid(numatm))
      allocate(segid(numatm))
      allocate(resname(numatm))
      allocate(atname(numatm))
      allocate(update(numatm))

      do i=1,numatm
        read(11,4) anum(i),segid(i),resid(i),resname(i),atname(i)
      enddo

C Reading the formatted atom list created using PSF:
      allocate(atlist(numatm))
      k=1
      I=0
      do while ( I .ne. -1 )
        read(1,'(i10)',IOSTAT=I) atlist(k)
        if ( I .eq. -1 ) goto 200
        k=k+1
      enddo
 200  continue
      numselat=k-1

C Reading the unformateed DCD files :
      totframe=startfrm
      do l=dcdstart,dcdend
        write(filename,'(a,a,a,i0,a)') trim(inputlocat),'/','step_',l,
     *  '.dcd'
        print*, "DCD being processed  ", filename
        open(10,file=trim(filename),status='old', form='unformatted')
        read(10) dummyc, nframes, (dummyi,i=1,8), dummyr, (dummyi,i=1,9)
        read(10) dummyi, dummyr
        read(10) natom
 15     format(a17,i6,a12,i6,a6)
        print 15,'The dcd contains  ',nframes,' frames and  ',natom,
     *  ' atoms'      
        allocate(x(nframes,natom))
        allocate(y(nframes,natom))
        allocate(z(nframes,natom))

C Comparing PSF and DCD file atoms:
     
        do i = 1, nframes, 1
          read(10) (d, j=1,6)
          read(10) (x(i,j),j=1,natom)
          read(10) (y(i,j),j=1,natom)
          read(10) (z(i,j),j=1,natom)
        enddo
        close(10)
C  Writing the first PDB file to use as a reference:
        if ( l .eq. 1 ) then
         if (numatm .ne. natom) then
           print*, 
     *  "Number of atoms in PSF and DCD don't match-Program 
     *   terminated"
          stop
         endif

         do j=1,natom
C i=startfrm,startfrm indicates starting and ending frame is same as the
C starting frame
          write(12,5) atom,anum(j),atname(j),resname(j),resid(j),
     *    (x(i,j),i=startfrm,startfrm),(y(i,j),i=startfrm,startfrm),
     *    (z(i,j),i=startfrm,startfrm),segid(j)
         enddo
        endif

        do i=startfrm,nframes,skipfrm
!         if ( i .eq. 1 ) then
         write(datfile,'(a,a,i0,a)') trim(location),'/coord_',
     *   totframe,'.dat'
         open(13,file=trim(datfile),status='new')
!         endif
 !        write(13,'("Current Frame",i10)') totframe
         if ( ( totframe .ge. startfrm ) .and. ( totframe .le. endfrm ))
     *   then
          do k=1,numselat
             write(13,16) atlist(k), atname(atlist(k)), x(i,atlist(k)),
     *       y(i,atlist(k)), z(i,atlist(k)), segid(atlist(k)),
     *       resname(atlist(k)), resid(atlist(k))
          enddo
         endif
         close(13)
          totframe=totframe+skipfrm
          if ( totframe .gt. endfrm ) goto 100
        enddo
 
        deallocate(x)
        deallocate(y)
        deallocate(z)
        
      enddo

 100  continue 
      print*, "Last frame processed ", totframe-skipfrm
      deallocate(anum)
      deallocate(resid)
      deallocate(segid)
      deallocate(resname)
      deallocate(atname)
      deallocate(atlist)
      stop
      end
